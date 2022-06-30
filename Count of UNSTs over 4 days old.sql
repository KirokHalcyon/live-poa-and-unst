SELECT * , (SELECT COUNT(*) AS Expr1
    FROM dbo.CalendarDim
    WHERE        (Date BETWEEN dbo.UNST_ZNST.PROCESS_DATE AND GETDATE()) AND (IsWeekend = 0) AND (IsHoliday = 0)) AS DAYS_OPEN
FROM [SharedServices].[dbo].[UNST_ZNST]
WHERE
					(  
						(	
							-- Exception Path
							AR_GL_NUM IN('1300','1322') -- THE EXCEL MACRO ONLY SHOWS THESE TWO GL NUMBERS TO AN ASSOCIATE
    AND PY_NUMBER IS NOT NULL -- THIS REALLY NEEDS TO BE HERE AS THE BOT IS RELIANT ON PY NUMBER INFO BEING PRESENT
    AND
    (-- THE SPREADSHEET MACRO ONLY SHOWS PY_NUMBERS THAT HAVE PA OR CM IN THEM
									PY_NUMBER LIKE '%PA%'
    OR
    PY_NUMBER LIKE '%CM%'
								)-- THE SPREADSHEET MACRO ALSO TRIES TO FILTER ON ALL OF THE SHIP INSTR
								 -- BUT THE BOT DOESN'T CARE ABOUT THOSE COLUMNS
							-- UNST REPORT DOES NOT CONTAIN A TERM COLUMN ALL RECORDS ARE ASSUMED TO BE TERMS = COD AS PART OF THE CODE FOR THE UNST TRILOGIE REPORT
						)
    AND
    (
							( -- Happy Path 1
							  -- PY_AMOUNT IS NOT STORED AS NUMERIC AND CAN'T BE STORED THAT WAY
							  -- THIS MAY NOT WORK
							  -- WILL HAVE TO CAST BAL AS VARCHAR
								CAST(BAL AS varchar(255)) = PY_AMOUNT
    AND PY_NUMBER NOT LIKE '%|%'
							)
    OR
    ( -- Happy Path 2
								PY_AMOUNT IS NULL
    AND PY_NUMBER NOT LIKE '%|%'
							)
    OR
    ( -- Happy Path 3 
								PY_NUMBER LIKE '%|%'
    AND
    (PY_AMOUNT IS NULL
    OR PY_AMOUNT LIKE '%|%')
							)
							 -- Happy Path 4 is identical to 3 except for how the bot handles the ones where the sum of PY Amounts equals BAL
						)
					)
    AND
    (   -- Excluding UNST records that are currently checked out, done, partial, set for pending and already owned
						CHECKED_OUT = 0
    AND [STATUS] IN('None','Started')
    AND PENDING = 0 
					)
    AND
    (	--Only get work for ACCOUNT that AR works
						ACCOUNT IN(SELECT [TrilogieAcctName]
    FROM [dbo].[POA_BranchAccountInfo]
    WHERE CloseDate IS NULL AND RunUNST = 1 AND BotWork = 1)
					)
    AND
    NOT (
						ACCOUNT = 'DIST' AND CUST = 180177
						)
    AND
    ( --The Bot will only lock records that are 4 business days since Process Date
						(	SELECT COUNT(*) AS Expr1
    FROM dbo.CalendarDim
    WHERE (Date BETWEEN dbo.UNST_ZNST.PROCESS_DATE AND GETDATE()) AND (IsWeekend = 0) AND (IsHoliday = 0)
						) <= 4
					)
			ORDER BY DAYS_OPEN ASC