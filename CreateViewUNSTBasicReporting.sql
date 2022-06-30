SELECT        
    [INVOICE] AS POA_Num, 
    [ACCOUNT] AS TrilAcctName, 
    IIF((LEN([POA COMMENTS FUT PAST]) > 1 AND [POA COMMENTS FUT PAST] IS NOT NULL), 1, 0) AS HasComments, 
    [POA COMMENTS FUT PAST], 
    [DATE] AS POA_Date, 
    DATENAME(year, [DATE]) AS POA_DateYear, 
    MONTH([DATE]) AS POA_DateMonthNum, 
    DATENAME(month, [DATE]) AS POA_DateMonth, 
    DATEPART(wk, [DATE]) AS POA_DateWeek, 
    IIF([END_DATE] IS NULL, CAST(GetDate() - [DATE] AS int), CAST([END_DATE] - [DATE] AS int)) AS TotalAgeInDays, 
    [ORIG POA AMT] AS OrigPOA_Amt, 
    [AR BAL NC] AS AR_Bal, 
    [POA BAL] AS CurrPOA_Amt, 
    IIF([ORIG POA AMT] = [POA BAL], 'Full', 'Partial') AS FullOrPartial, 
    IIF([TERMS] = 'COD', 1, 0) AS HasCOD_Terms, 
    [INSERT_DATE] AS InsertDate, 
    [AR_GL_NUM] AS AR_GL_Num, 
    [CHECKED_OUT] AS CheckedOut, 
    [OWNER] AS OwnerID, 
    [STATUS] AS CurrStatus, 
    [PENDING] AS Pending, 
    [START_DATE] AS StartDate, 
    [UPDATE_DATE] AS UpdateDate, 
    [END_DATE] AS EndDate,
    (SELECT        BusinessDayOfMonth
    FROM            CalendarDim
    WHERE        [Date] = CAST(GetDate() AS date)) AS BusinessDayToday,
    (SELECT        WeekDayName
    FROM            CalendarDim
    WHERE        [Date] = CAST(GetDate() AS date)) AS WeekDayNameToday, 
    DATENAME(year, [END_DATE]) AS POA_DoneYear, 
    MONTH([END_DATE]) AS POA_DoneMonthNum, 
    DATENAME(month, [END_DATE]) AS POA_DoneMonth, 
    DATEPART(wk, [END_DATE]) AS POA_DoneWeek, 
    IIF([START_DATE] IS NULL, CAST(GetDate() - [DATE] AS int), 
        IIF([UPDATE_DATE] IS NULL, CAST([START_DATE] - [DATE] AS int), 
            IIF([END_DATE] IS NULL, CAST([UPDATE_DATE] - [START_DATE] AS int), CAST([END_DATE] - [START_DATE] AS int)))) AS DaysSinceLastUpdate, 
    IIF(DATEDIFF(d, [DATE], CAST(GetDate() AS DATE)) <= 3, 1, 0) AS ThreeDaysOldOrLess, 
    IIF(DATEDIFF(d, [DATE], CAST(GetDate() AS DATE)) <= 5, 1, 0) AS FiveDaysOldOrLess, 
    IIF([DATE] BETWEEN DATEFROMPARTS(Year(GetDate()), Month(GetDate()), 1) 
        AND GetDate(), 1, 0) AS ThisMonth, 
    IIF([DATE] BETWEEN DATEFROMPARTS(Year(DateAdd(m, - 1, GetDate())), Month(DateAdd(m, - 1, GetDate())), 1) 
        AND DateAdd(d, - 1, DATEFROMPARTS(Year(GetDate()), Month(GetDate()), 1)), 1, 0) AS LastMonth, 
    IIF([DATE] < DATEFROMPARTS(Year(DateAdd(m, - 1, GetDate())), Month(DateAdd(m, - 1, GetDate())), 1), 1, 0) AS Older, 
    [POA_SOP_Count] = CASE WHEN
        (SELECT        BusinessDayOfMonth
        FROM            CalendarDim
        WHERE        [Date] = CAST(GetDate() AS date)) = 1 THEN IIF([DATE] BETWEEN DATEFROMPARTS(Year(DateAdd(m, - 1, GetDate())), Month(DateAdd(m, - 1, GetDate())), 1) AND GetDate(), 1, 0) WHEN
        (SELECT        BusinessDayOfMonth
        FROM            CalendarDim
        WHERE        [Date] = CAST(GetDate() AS date)) BETWEEN 2 AND 10 THEN IIF([DATE] BETWEEN DATEFROMPARTS(Year(GetDate()), Month(GetDate()), 1) AND GetDate(), 1, 0) WHEN
        (SELECT        BusinessDayOfMonth
        FROM            CalendarDim
        WHERE        [Date] = CAST(GetDate() AS date)) > 10 THEN IIF([DATE] BETWEEN DATEFROMPARTS(Year(DateAdd(d, - 3, GetDate())), Month(DateAdd(d, - 3, GetDate())), Day(DateAdd(d, - 3, GetDate()))) AND GetDate(), 1, 0) END, 
    [POA_SOP_Category] = CASE WHEN
        (SELECT        BusinessDayOfMonth
        FROM            CalendarDim
        WHERE        [Date] = CAST(GetDate() AS date)) = 1 THEN IIF([DATE] BETWEEN DATEFROMPARTS(Year(DateAdd(m, - 1, GetDate())), Month(DateAdd(m, - 1, GetDate())), 1) AND GetDate(), '1st', NULL) WHEN
        (SELECT        BusinessDayOfMonth
        FROM            CalendarDim
        WHERE        [Date] = CAST(GetDate() AS date)) BETWEEN 2 AND 10 THEN IIF([DATE] BETWEEN DATEFROMPARTS(Year(GetDate()), Month(GetDate()), 1) AND GetDate(), '2nd to 10th', NULL) WHEN
        (SELECT        BusinessDayOfMonth
        FROM            CalendarDim
        WHERE        [Date] = CAST(GetDate() AS date)) > 10 THEN IIF([DATE] BETWEEN DATEFROMPARTS(Year(DateAdd(d, - 3, GetDate())), Month(DateAdd(d, - 3, GetDate())), Day(DateAdd(d, - 3, GetDate()))) AND GetDate(), '>10th', NULL) 
    END
FROM            [dbo].[UNST_ZNST]