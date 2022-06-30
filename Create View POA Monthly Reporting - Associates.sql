--USE [SharedServices]
--GO

--DROP VIEW [dbo].[POA_Reporting-Associates]
--GO

--CREATE VIEW [dbo].[POA_Reporting-Associates]
--AS
SELECT TempAcctNDate.TrilAcctName, TempAcctNDate.CombinedDate, TempAcctNDate.OwnerID, TempAcctNDate.HasCOD_Terms,
       POA_Associates.FullName,
       CalendarDim.WeekOfYear, CalendarDim.FiscalWeekOfYear, 
       CalendarDim.Month, CalendarDim.FiscalMonth, CalendarDim.MonthName, 
       CalendarDim.Quarter, CalendarDim.FiscalQuarter, CalendarDim.QuarterName, CalendarDim.FiscalQuarterName, 
       CalendarDim.Year, CalendarDim.FiscalYear, 
       CalendarDim.MMYYYY, CalendarDim.FiscalMMYYYY, CalendarDim.MonthYear,
       POA_PendingClicked.CountOfPendingClicks, POA_PendingClicked.SumOfPendingCurrPOA_AmtClicked, POA_PendingClicked.SumOfAmtAllocated,
       POA_Partial.CountOfPartialPOA_Num, POA_Partial.SumOfPartialPOA_Amt,
       POA_Done.CountOfDonePOA_Num, POA_Done.SumOfFinalPOA_Amt
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
                (SELECT POA_BasicReporting.TrilAcctName, POA_BasicReporting.OwnerID,
                        HasCOD_Terms,
                        CONVERT(date,[PendingDate]) AS CombinedDate
                   FROM POA_PendingLog 
                        INNER JOIN POA_BasicReporting
                        ON POA_PendingLog.POANum = POA_BasicReporting.POA_Num
                  GROUP BY POA_BasicReporting.TrilAcctName, CONVERT(date, PendingDate), POA_BasicReporting.OwnerID, HasCOD_Terms
                  
                  UNION

                 SELECT TrilAcctName, OwnerID, HasCOD_Terms,
                        CONVERT(DATE, EndDate) AS CombinedDate
                   FROM POA_BasicReporting
                  WHERE EndDate IS NOT NULL 
                  GROUP BY TrilAcctName, 
                        CONVERT(date, EndDate), OwnerID, HasCOD_Terms
                ) AS TempAcctNDate
        ON CalendarDim.[Date] = TempAcctNDate.CombinedDate
        INNER JOIN POA_Associates
        ON TempAcctNDate.OwnerID = POA_Associates.UserID
        LEFT JOIN
        (SELECT COUNT([POANum]) AS CountOfPendingClicks, 
                POA_PendingLog.TrilAcctName, POA_PendingLog.OwnerID,   
                POA_BasicReporting.HasCOD_Terms,     
                CONVERT(date,[PendingDate]) AS PendingDate, 
                SUM(POA_PendingLog.CurrPOA_Amt)*-1 AS SumOfPendingCurrPOA_AmtClicked, 
                SUM(AmtAllocated) AS SumOfAmtAllocated
           FROM POA_PendingLog 
                INNER JOIN POA_BasicReporting
                ON POA_PendingLog.POANum = POA_BasicReporting.POA_Num
        GROUP BY POA_PendingLog.TrilAcctName, CONVERT(date, PendingDate), POA_PendingLog.OwnerID, POA_BasicReporting.HasCOD_Terms) AS POA_PendingClicked
ON TempAcctNDate.CombinedDate = POA_PendingClicked.PendingDate 
        AND TempAcctNDate.TrilAcctName = POA_PendingClicked.TrilAcctName 
        AND TempAcctNDate.OwnerID = POA_PendingClicked.OwnerID
        AND TempAcctNDate.HasCOD_Terms = POA_PendingClicked.HasCOD_Terms
LEFT JOIN
(SELECT COUNT(POA_Num) AS CountOfDonePOA_Num, 
        TrilAcctName,
        OwnerID,        
        HasCOD_Terms,
        CONVERT(DATE, EndDate) AS CompletedDate, 
        SUM(CurrPOA_Amt*-1) AS SumOfFinalPOA_Amt
FROM POA_BasicReporting
WHERE [CurrStatus] = 'Done' AND EndDate IS NOT NULL 
GROUP BY TrilAcctName, CONVERT(date, EndDate), OwnerID, HasCOD_Terms) AS POA_Done
ON TempAcctNDate.CombinedDate = POA_Done.CompletedDate 
        AND TempAcctNDate.TrilAcctName = POA_Done.TrilAcctName 
        AND TempAcctNDate.OwnerID = POA_Done.OwnerID
        AND TempAcctNDate.HasCOD_Terms = POA_Done.HasCOD_Terms
LEFT JOIN
(SELECT COUNT(POA_Num) AS CountOfPartialPOA_Num, 
        TrilAcctName,
        OwnerID,        
        HasCOD_Terms,
        CONVERT(DATE, EndDate) AS PartialDate, 
        SUM(CurrPOA_Amt*-1) AS SumOfPartialPOA_Amt
FROM POA_BasicReporting
WHERE [CurrStatus] = 'Partial' AND EndDate IS NOT NULL 
GROUP BY TrilAcctName, CONVERT(date, EndDate), OwnerID, HasCOD_Terms) AS POA_Partial
ON TempAcctNDate.CombinedDate = POA_Partial.PartialDate 
        AND TempAcctNDate.TrilAcctName = POA_Partial.TrilAcctName 
        AND TempAcctNDate.OwnerID = POA_Partial.OwnerID
        AND TempAcctNDate.HasCOD_Terms = POA_Partial.HasCOD_Terms

--GO