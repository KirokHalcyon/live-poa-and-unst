USE [SharedServices]
GO

CREATE VIEW [dbo].[POA_DailyPOAPNumbers_v2]
AS

SELECT [ACCOUNT]
	  ,[POACreatedOnWeekDay] = CASE
	  WHEN DATENAME(w, [DATE]) IN('Saturday','Sunday','Monday') AND DATEDIFF(wk,[DATE],GetDate()) BETWEEN 0 AND 1
	  THEN 'Sat, Sun or Mon'
	  WHEN DATENAME(w, [DATE]) IN('Tuesday') AND DATEDIFF(wk,[DATE],GetDate()) = 0
	  THEN 'Tue'
	  WHEN DATENAME(w, [DATE]) IN('Wednesday') AND DATEDIFF(wk,[DATE],GetDate()) = 1
	  THEN 'Wed'
	  WHEN DATENAME(w, [DATE]) IN('Thursday') AND DATEDIFF(wk,[DATE],GetDate()) = 1
	  THEN 'Thu'
	  WHEN DATENAME(w, [DATE]) IN('Friday') AND DATEDIFF(wk,[DATE],GetDate()) = 1
	  THEN 'Fri'
	  ELSE 'OLDER'
	  END
      ,COUNT([INVOICE]) As CountOFPOAs
      ,SUM([ORIG POA AMT]) As SumOfOrigPOA_Amt
      ,SUM([AR BAL NC]) As SumOfAR_Bal
      ,SUM([POA BAL]) As SumOfPOA_Bal
	  ,DATENAME(w, GetDate()) As CurrWeekday	  
	  ,[ARtoWorkOn] = CASE
	  WHEN DATENAME(w, [DATE]) IN('Saturday','Sunday','Monday') AND DATEDIFF(wk,[DATE],GetDate()) BETWEEN 0 AND 1
	  THEN '4-Thursday'
	  WHEN DATENAME(w, [DATE]) IN('Tuesday') AND DATEDIFF(wk,[DATE],GetDate()) = 0
	  THEN '5-Friday'
	  WHEN DATENAME(w, [DATE]) IN('Wednesday') AND DATEDIFF(wk,[DATE],GetDate()) = 1
	  THEN '1-Monday'
	  WHEN DATENAME(w, [DATE]) IN('Thursday') AND DATEDIFF(wk,[DATE],GetDate()) = 1
	  THEN '2-Tuesday'
	  WHEN DATENAME(w, [DATE]) IN('Friday') AND DATEDIFF(wk,[DATE],GetDate()) = 1
	  THEN '3-Wednesday'
	  ELSE 'OLDER'
	  END
FROM [dbo].[POA_ZOAP]
WHERE [STATUS] NOT IN('Done','Partial') AND CHECKED_OUT = 0
GROUP BY ACCOUNT, 
  (CASE
	  WHEN DATENAME(w, [DATE]) IN('Saturday','Sunday','Monday') AND DATEDIFF(wk,[DATE],GetDate()) BETWEEN 0 AND 1
	  THEN 'Sat, Sun or Mon'
	  WHEN DATENAME(w, [DATE]) IN('Tuesday') AND DATEDIFF(wk,[DATE],GetDate()) = 0
	  THEN 'Tue'
	  WHEN DATENAME(w, [DATE]) IN('Wednesday') AND DATEDIFF(wk,[DATE],GetDate()) = 1
	  THEN 'Wed'
	  WHEN DATENAME(w, [DATE]) IN('Thursday') AND DATEDIFF(wk,[DATE],GetDate()) = 1
	  THEN 'Thu'
	  WHEN DATENAME(w, [DATE]) IN('Friday') AND DATEDIFF(wk,[DATE],GetDate()) = 1
	  THEN 'Fri'
	  ELSE 'OLDER'
	  END), 
  (CASE
	  WHEN DATENAME(w, [DATE]) IN('Saturday','Sunday','Monday') AND DATEDIFF(wk,[DATE],GetDate()) BETWEEN 0 AND 1
	  THEN '4-Thursday'
	  WHEN DATENAME(w, [DATE]) IN('Tuesday') AND DATEDIFF(wk,[DATE],GetDate()) = 0
	  THEN '5-Friday'
	  WHEN DATENAME(w, [DATE]) IN('Wednesday') AND DATEDIFF(wk,[DATE],GetDate()) = 1
	  THEN '1-Monday'
	  WHEN DATENAME(w, [DATE]) IN('Thursday') AND DATEDIFF(wk,[DATE],GetDate()) = 1
	  THEN '2-Tuesday'
	  WHEN DATENAME(w, [DATE]) IN('Friday') AND DATEDIFF(wk,[DATE],GetDate()) = 1
	  THEN '3-Wednesday'
	  ELSE 'OLDER'
	  END)
GO


