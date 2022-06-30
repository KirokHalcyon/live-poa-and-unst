USE [SharedServices]
GO

--CREATE VIEW [dbo].[POA_DailyPOAPNumberSummary]
--AS

SELECT 
    AllAccounts.TrilAcctName,
    AllAccounts.POA_SOP_Category,
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
    CountOfOpenPOA_Num,
    SumOfOpenOrigPOA_Amt, 
    SumOfOpenAR_Bal, 
    SumOfOpenCurrPOA_Amt
FROM
    (SELECT DISTINCT 
        TrilAcctName,
        POA_SOP_Category,
        HasComments, 
        BusinessDayToday, 
        WeekDayNameToday
     FROM dbo.POA_BasicReporting
     WHERE 
        HasComments = 1
        AND POA_SOP_Count = 1
    ) AS AllAccounts
    
    LEFT JOIN

    (SELECT        
        COUNT(POA_Num) AS CountOfCOD_POA_Num, 
        TrilAcctName, 
        POA_SOP_Category, 
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
        AND (POA_SOP_Count = 1) 
        AND HasComments = 1 
        AND HasCOD_Terms = 1
    GROUP BY 
        TrilAcctName, 
        POA_SOP_Category, 
        HasComments, 
        BusinessDayToday, 
        WeekDayNameToday
    ) AS COD_Term 
    ON AllAccounts.TrilAcctName = COD_Term.TrilAcctName
        AND AllAccounts.POA_SOP_Category = COD_Term.POA_SOP_Category
        AND AllAccounts.BusinessDayToday = COD_Term.BusinessDayToday
        AND AllAccounts.WeekdayNameToday = COD_Term.WeekdayNameToday

    LEFT JOIN

    (SELECT        
        COUNT(POA_Num) AS CountOfNoCOD_POA_Num, 
        TrilAcctName, 
        POA_SOP_Category, 
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
        AND (POA_SOP_Count = 1) 
        AND HasComments = 1 
        AND HasCOD_Terms = 0
    GROUP BY 
        TrilAcctName, 
        POA_SOP_Category, 
        HasComments, 
        BusinessDayToday, 
        WeekDayNameToday
    ) AS NoCOD_Term
    ON AllAccounts.TrilAcctName = NoCOD_Term.TrilAcctName
        AND AllAccounts.POA_SOP_Category = NoCOD_Term.POA_SOP_Category
        AND AllAccounts.BusinessDayToday = NoCOD_Term.BusinessDayToday
        AND AllAccounts.WeekdayNameToday = NoCOD_Term.WeekdayNameToday

GO
