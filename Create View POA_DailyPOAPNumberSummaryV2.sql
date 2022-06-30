USE [SharedServices]
GO

CREATE VIEW [dbo].[POA_DailyPOAPNumberSummary_v2]
AS

SELECT 
    AllAccounts.TrilAcctName,
    AllAccounts.POACreatedOnWeekDay,
    AllAccounts.BusinessDayToday,
    AllAccounts.WeekDayNameToday,
    AllAccounts.HasComments,
    CountOfCOD_POA_Num,
    SumOfCOD_OrigPOA_Amt, 
    SumOfCOD_AR_Bal, 
    SumOfCOD_CurrPOA_Amt, 
    CountOfNoCOD_POA_Num,
    SumOfNoCOD_OrigPOA_Amt, 
    SumOfNoCOD_AR_Bal, 
    SumOfNoCOD_CurrPOA_Amt
FROM
    (SELECT DISTINCT 
        TrilAcctName,
        [POACreatedOnWeekDay] = CASE
            WHEN DATENAME(w, [POA_Date]) IN('Saturday','Sunday','Monday') AND DATEDIFF(wk,[POA_Date],GetDate()) BETWEEN 0 AND 1
                THEN 'Sat, Sun or Mon'
            WHEN DATENAME(w, [POA_Date]) IN('Tuesday') AND DATEDIFF(wk,[POA_Date],GetDate()) = 0
                THEN 'Tue'
            WHEN DATENAME(w, [POA_Date]) IN('Wednesday') AND DATEDIFF(wk,[POA_Date],GetDate()) = 1
                THEN 'Wed'
            WHEN DATENAME(w, [POA_Date]) IN('Thursday') AND DATEDIFF(wk,[POA_Date],GetDate()) = 1
                THEN 'Thu'
            WHEN DATENAME(w, [POA_Date]) IN('Friday') AND DATEDIFF(wk,[POA_Date],GetDate()) = 1
                THEN 'Fri'
            ELSE 'OLDER'
        END,
        HasComments, 
        BusinessDayToday, 
        WeekDayNameToday

     FROM dbo.POA_BasicReporting
     WHERE 
        HasComments = 1
    ) AS AllAccounts
    
    LEFT JOIN

    (SELECT        
        COUNT(POA_Num) AS CountOfCOD_POA_Num, 
        TrilAcctName, 
        [POACreatedOnWeekDay] = CASE
            WHEN DATENAME(w, [POA_Date]) IN('Saturday','Sunday','Monday') AND DATEDIFF(wk,[POA_Date],GetDate()) BETWEEN 0 AND 1
                THEN 'Sat, Sun or Mon'
            WHEN DATENAME(w, [POA_Date]) IN('Tuesday') AND DATEDIFF(wk,[POA_Date],GetDate()) = 0
                THEN 'Tue'
            WHEN DATENAME(w, [POA_Date]) IN('Wednesday') AND DATEDIFF(wk,[POA_Date],GetDate()) = 1
                THEN 'Wed'
            WHEN DATENAME(w, [POA_Date]) IN('Thursday') AND DATEDIFF(wk,[POA_Date],GetDate()) = 1
                THEN 'Thu'
            WHEN DATENAME(w, [POA_Date]) IN('Friday') AND DATEDIFF(wk,[POA_Date],GetDate()) = 1
                THEN 'Fri'
            ELSE 'OLDER'
        END, 
        SUM(OrigPOA_Amt) AS SumOfCOD_OrigPOA_Amt, 
        SUM(AR_Bal) AS SumOfCOD_AR_Bal, 
        SUM(CurrPOA_Amt) AS SumOfCOD_CurrPOA_Amt, 
        HasComments, 
        BusinessDayToday, 
        WeekDayNameToday
    FROM dbo.POA_BasicReporting
    WHERE
        (Pending = 0) 
        AND (CheckedOut = 0) 
        AND (AR_GL_Num <> '1310') 
        AND (CurrStatus NOT IN('Done','Partial'))  
        AND HasComments = 1 
        AND HasCOD_Terms = 1
    GROUP BY 
        TrilAcctName, 
        CASE
            WHEN DATENAME(w, [POA_Date]) IN('Saturday','Sunday','Monday') AND DATEDIFF(wk,[POA_Date],GetDate()) BETWEEN 0 AND 1
                THEN 'Sat, Sun or Mon'
            WHEN DATENAME(w, [POA_Date]) IN('Tuesday') AND DATEDIFF(wk,[POA_Date],GetDate()) = 0
                THEN 'Tue'
            WHEN DATENAME(w, [POA_Date]) IN('Wednesday') AND DATEDIFF(wk,[POA_Date],GetDate()) = 1
                THEN 'Wed'
            WHEN DATENAME(w, [POA_Date]) IN('Thursday') AND DATEDIFF(wk,[POA_Date],GetDate()) = 1
                THEN 'Thu'
            WHEN DATENAME(w, [POA_Date]) IN('Friday') AND DATEDIFF(wk,[POA_Date],GetDate()) = 1
                THEN 'Fri'
            ELSE 'OLDER'
        END, 
        HasComments, 
        BusinessDayToday, 
        WeekDayNameToday
    ) AS COD_Term 
    ON AllAccounts.TrilAcctName = COD_Term.TrilAcctName
        AND AllAccounts.POACreatedOnWeekDay = COD_Term.POACreatedOnWeekDay
        AND AllAccounts.BusinessDayToday = COD_Term.BusinessDayToday
        AND AllAccounts.WeekdayNameToday = COD_Term.WeekdayNameToday

    LEFT JOIN

    (SELECT        
        COUNT(POA_Num) AS CountOfNoCOD_POA_Num, 
        TrilAcctName, 
        [POACreatedOnWeekDay] = CASE
            WHEN DATENAME(w, [POA_Date]) IN('Saturday','Sunday','Monday') AND DATEDIFF(wk,[POA_Date],GetDate()) BETWEEN 0 AND 1
                THEN 'Sat, Sun or Mon'
            WHEN DATENAME(w, [POA_Date]) IN('Tuesday') AND DATEDIFF(wk,[POA_Date],GetDate()) = 0
                THEN 'Tue'
            WHEN DATENAME(w, [POA_Date]) IN('Wednesday') AND DATEDIFF(wk,[POA_Date],GetDate()) = 1
                THEN 'Wed'
            WHEN DATENAME(w, [POA_Date]) IN('Thursday') AND DATEDIFF(wk,[POA_Date],GetDate()) = 1
                THEN 'Thu'
            WHEN DATENAME(w, [POA_Date]) IN('Friday') AND DATEDIFF(wk,[POA_Date],GetDate()) = 1
                THEN 'Fri'
            ELSE 'OLDER'
        END, 
        SUM(OrigPOA_Amt) AS SumOfNoCOD_OrigPOA_Amt, 
        SUM(AR_Bal) AS SumOfNoCOD_AR_Bal, 
        SUM(CurrPOA_Amt) AS SumOfNoCOD_CurrPOA_Amt, 
        HasComments, 
        BusinessDayToday, 
        WeekDayNameToday
    FROM dbo.POA_BasicReporting
    WHERE
        (Pending = 0) 
        AND (CheckedOut = 0) 
        AND (AR_GL_Num <> '1310') 
        AND (CurrStatus NOT IN('Done','Partial'))  
        AND HasComments = 1 
        AND HasCOD_Terms = 0
    GROUP BY 
        TrilAcctName, 
        CASE
            WHEN DATENAME(w, [POA_Date]) IN('Saturday','Sunday','Monday') AND DATEDIFF(wk,[POA_Date],GetDate()) BETWEEN 0 AND 1
                THEN 'Sat, Sun or Mon'
            WHEN DATENAME(w, [POA_Date]) IN('Tuesday') AND DATEDIFF(wk,[POA_Date],GetDate()) = 0
                THEN 'Tue'
            WHEN DATENAME(w, [POA_Date]) IN('Wednesday') AND DATEDIFF(wk,[POA_Date],GetDate()) = 1
                THEN 'Wed'
            WHEN DATENAME(w, [POA_Date]) IN('Thursday') AND DATEDIFF(wk,[POA_Date],GetDate()) = 1
                THEN 'Thu'
            WHEN DATENAME(w, [POA_Date]) IN('Friday') AND DATEDIFF(wk,[POA_Date],GetDate()) = 1
                THEN 'Fri'
            ELSE 'OLDER'
        END, 
        HasComments, 
        BusinessDayToday, 
        WeekDayNameToday
    ) AS NoCOD_Term
    ON AllAccounts.TrilAcctName = NoCOD_Term.TrilAcctName
        AND AllAccounts.POACreatedOnWeekDay = NoCOD_Term.POACreatedOnWeekDay
        AND AllAccounts.BusinessDayToday = NoCOD_Term.BusinessDayToday
        AND AllAccounts.WeekdayNameToday = NoCOD_Term.WeekdayNameToday

GO
