USE [SharedServices]
GO

--DROP VIEW [dbo].[UNST_Reporting-Associates]
--GO

CREATE VIEW [dbo].[UNST_Reporting-Associates]
AS
SELECT TempAcctNDate.TrilAcctName, TempAcctNDate.CombinedDate, TempAcctNDate.OwnerID,
       POA_Associates.FullName,
       CalendarDim.WeekOfYear, CalendarDim.FiscalWeekOfYear, 
       CalendarDim.Month, CalendarDim.FiscalMonth, CalendarDim.MonthName, 
       CalendarDim.Quarter, CalendarDim.FiscalQuarter, CalendarDim.QuarterName, CalendarDim.FiscalQuarterName, 
       CalendarDim.Year, CalendarDim.FiscalYear, 
       CalendarDim.MMYYYY, CalendarDim.FiscalMMYYYY, CalendarDim.MonthYear,
       UNST_Partial.CountOfPartialUNST, UNST_Partial.SumOfPartialOrigInvAmt, UNST_Partial.SumOfPartialCurrInvAmt,
       UNST_Done.CountOfDoneUNST, UNST_Done.SumOfDoneOrigInvAmt, UNST_Done.SumOfDoneCurrInvAmt
  FROM 
        (SELECT [Date], 
                WeekOfYear, FiscalWeekOfYear, 
                Month, FiscalMonth, MonthName, 
                Quarter, FiscalQuarter, QuarterName, FiscalQuarterName, 
                Year, FiscalYear, 
                MMYYYY, FiscalMMYYYY, MonthYear
           FROM CalendarDim
          WHERE (((CalendarDim.[Date]) >= DateAdd(month,DateDiff(month,'2/1/1901',GetDate()),'1/1/1900') 
            AND (CalendarDim.[Date]) <= GetDate()))
        ) AS CalendarDim
        INNER JOIN 
        (SELECT UNST_BasicReporting.TrilAcctName, UNST_BasicReporting.OwnerID,
                CONVERT(date, [EndDate]) AS CombinedDate
           FROM UNST_BasicReporting
          WHERE EndDate IS NOT NULL
          GROUP BY UNST_BasicReporting.TrilAcctName, CONVERT(date, [EndDate]), UNST_BasicReporting.OwnerID
        ) AS TempAcctNDate
        ON CalendarDim.[Date] = TempAcctNDate.CombinedDate 
INNER JOIN POA_Associates
ON TempAcctNDate.OwnerID = POA_Associates.UserID
LEFT JOIN
(SELECT COUNT(InvNum) AS CountOfDoneUNST,
        TrilAcctName, 
        OwnerID, 
        CONVERT(DATE, EndDate) AS DoneDate,
        SUM(OrigInvBal) AS SumOfDoneOrigInvAmt,
        SUM(CurrInvBal) AS SumOfDoneCurrInvAmt
FROM UNST_BasicReporting
WHERE [CurrStatus] = 'Done' AND EndDate IS NOT NULL
GROUP BY TrilAcctName, CONVERT(DATE, EndDate), OwnerID) AS UNST_Done
ON TempAcctNDate.CombinedDate = UNST_Done.DoneDate
  AND TempAcctNDate.OwnerID = UNST_Done.OwnerID
  AND TempAcctNDate.TrilAcctName = UNST_Done.TrilAcctName
LEFT JOIN
(SELECT COUNT(InvNum) AS CountOfPartialUNST,
        TrilAcctName, 
        OwnerID, 
        CONVERT(DATE, EndDate) AS PartialDate,
        SUM(OrigInvBal) AS SumOfPartialOrigInvAmt,
        SUM(CurrInvBal) AS SumOfPartialCurrInvAmt
FROM UNST_BasicReporting
WHERE [CurrStatus] = 'Partial' AND EndDate IS NOT NULL
GROUP BY TrilAcctName, CONVERT(DATE, EndDate), OwnerID) AS UNST_Partial
ON TempAcctNDate.CombinedDate = UNST_Partial.PartialDate
  AND TempAcctNDate.OwnerID = UNST_Partial.OwnerID
  AND TempAcctNDate.TrilAcctName = UNST_Partial.TrilAcctName

GO