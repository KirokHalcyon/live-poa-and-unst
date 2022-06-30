--USE [SharedServices]
--GO

--DROP VIEW [dbo].[POA_Reporting-Branches]
--GO

--CREATE VIEW [dbo].[POA_Reporting-Branches]
--AS
SELECT TempAcctNDate.TrilAcctName, TempAcctNDate.CombinedDate, TempAcctNDate.OwnerID, TempAcctNDate.HasCOD_Terms,
       CalendarDim.WeekOfYear, CalendarDim.FiscalWeekOfYear, 
       CalendarDim.Month, CalendarDim.FiscalMonth, CalendarDim.MonthName, 
       CalendarDim.Quarter, CalendarDim.FiscalQuarter, CalendarDim.QuarterName, CalendarDim.FiscalQuarterName, 
       CalendarDim.Year, CalendarDim.FiscalYear, 
       CalendarDim.MMYYYY, CalendarDim.FiscalMMYYYY, CalendarDim.MonthYear,
       POA_Inserted.CountOfPOA_NumInserted, POA_Inserted.SumOfOrigPOA_Amt,
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
                (SELECT POA_BasicReporting.TrilAcctName, 
                        HasCOD_Terms,
                        IIf(POA_BasicReporting.OwnerID <> 'BRANCH' AND POA_BasicReporting.OwnerID <> 'None', 'SAC', POA_BasicReporting.OwnerID) AS OwnerID,  
                        CONVERT(date,[InsertDate]) AS CombinedDate 
                   FROM POA_BasicReporting
                  GROUP BY POA_BasicReporting.TrilAcctName, 
                        HasCOD_Terms, 
                        CONVERT(date,[InsertDate]), 
                        IIf(POA_BasicReporting.OwnerID <> 'BRANCH' AND POA_BasicReporting.OwnerID <> 'None', 'SAC', POA_BasicReporting.OwnerID)
                
                UNION

                SELECT  POA_PendingLog.TrilAcctName, 
                        HasCOD_Terms,
                        IIf(POA_PendingLog.OwnerID <> 'BRANCH' AND POA_PendingLog.OwnerID <> 'None', 'SAC', POA_PendingLog.OwnerID) AS OwnerID,
                        CONVERT(date,[PendingDate]) AS CombinedDate
                   FROM POA_PendingLog 
                        INNER JOIN POA_BasicReporting
                        ON POA_PendingLog.POANum = POA_BasicReporting.POA_Num
                  GROUP BY POA_PendingLog.TrilAcctName, 
                        HasCOD_Terms, 
                        CONVERT(date, PendingDate), 
                        IIf(POA_PendingLog.OwnerID <> 'BRANCH' AND POA_PendingLog.OwnerID <> 'None', 'SAC', POA_PendingLog.OwnerID)

                UNION

                SELECT  POA_BasicReporting.TrilAcctName,
                        HasCOD_Terms,
                        IIf(POA_BasicReporting.OwnerID <> 'BRANCH' AND POA_BasicReporting.OwnerID <> 'None', 'SAC', POA_BasicReporting.OwnerID) AS OwnerID,
                        CONVERT(DATE, EndDate) AS CombinedDate
                   FROM POA_BasicReporting
                  GROUP BY POA_BasicReporting.TrilAcctName, 
                        HasCOD_Terms, 
                        CONVERT(date, EndDate), 
                        IIf(POA_BasicReporting.OwnerID <> 'BRANCH' AND POA_BasicReporting.OwnerID <> 'None', 'SAC', POA_BasicReporting.OwnerID)
                ) AS TempAcctNDate
        ON CalendarDim.[Date] = TempAcctNDate.CombinedDate
LEFT JOIN
        (SELECT COUNT(POA_Num) AS CountOfPOA_NumInserted, 
                POA_BasicReporting.TrilAcctName, 
                HasCOD_Terms,
                IIf(POA_BasicReporting.OwnerID <> 'BRANCH' AND POA_BasicReporting.OwnerID <> 'None', 'SAC', POA_BasicReporting.OwnerID) AS OwnerID,
                CONVERT(date,[InsertDate]) AS InsertDate, 
                SUM(OrigPOA_Amt) AS SumOfOrigPOA_Amt
           FROM POA_BasicReporting
          GROUP BY POA_BasicReporting.TrilAcctName, 
                HasCOD_Terms, 
                CONVERT(date,[InsertDate]), 
                IIf(POA_BasicReporting.OwnerID <> 'BRANCH' AND POA_BasicReporting.OwnerID <> 'None', 'SAC', POA_BasicReporting.OwnerID)
        ) AS POA_Inserted
ON TempAcctNDate.CombinedDate = POA_Inserted.InsertDate 
        AND TempAcctNDate.TrilAcctName = POA_Inserted.TrilAcctName
        AND TempAcctNDate.OwnerID = POA_Inserted.OwnerID
        AND TempAcctNDate.HasCOD_Terms = POA_Inserted.HasCOD_Terms
LEFT JOIN
        (SELECT COUNT([POANum]) AS CountOfPendingClicks,  
                POA_PendingLog.TrilAcctName, 
                HasCOD_Terms,
                IIf(POA_PendingLog.OwnerID <> 'BRANCH' AND POA_PendingLog.OwnerID <> 'None', 'SAC', POA_PendingLog.OwnerID) AS OwnerID,
                CONVERT(date,[PendingDate]) AS PendingDate, 
                SUM(POA_PendingLog.CurrPOA_Amt)*-1 AS SumOfPendingCurrPOA_AmtClicked, 
                SUM(POA_PendingLog.AmtAllocated) AS SumOfAmtAllocated
           FROM POA_PendingLog 
                INNER JOIN POA_BasicReporting
                ON POA_PendingLog.POANum = POA_BasicReporting.POA_Num
          GROUP BY POA_PendingLog.TrilAcctName, 
                HasCOD_Terms, 
                CONVERT(date, PendingDate), 
                IIf(POA_PendingLog.OwnerID <> 'BRANCH' AND POA_PendingLog.OwnerID <> 'None', 'SAC', POA_PendingLog.OwnerID)
        ) AS POA_PendingClicked
ON TempAcctNDate.CombinedDate = POA_PendingClicked.PendingDate 
        AND TempAcctNDate.TrilAcctName = POA_PendingClicked.TrilAcctName
        AND TempAcctNDate.OwnerID = POA_PendingClicked.OwnerID
        AND TempAcctNDate.HasCOD_Terms = POA_PendingClicked.HasCOD_Terms
LEFT JOIN
        (SELECT COUNT(POA_Num) AS CountOfDonePOA_Num, 
                POA_BasicReporting.TrilAcctName, 
                HasCOD_Terms,
                IIf(POA_BasicReporting.OwnerID <> 'BRANCH' AND POA_BasicReporting.OwnerID <> 'None', 'SAC', POA_BasicReporting.OwnerID) AS OwnerID,
                CONVERT(DATE, EndDate) AS CompletedDate, 
                SUM(CurrPOA_Amt*-1) AS SumOfFinalPOA_Amt
           FROM POA_BasicReporting
          WHERE CurrStatus = 'Done'
          GROUP BY POA_BasicReporting.TrilAcctName, 
                HasCOD_Terms, 
                CONVERT(date, EndDate), 
                IIf(POA_BasicReporting.OwnerID <> 'BRANCH' AND POA_BasicReporting.OwnerID <> 'None', 'SAC', POA_BasicReporting.OwnerID)
        ) AS POA_Done
ON TempAcctNDate.CombinedDate = POA_Done.CompletedDate 
        AND TempAcctNDate.TrilAcctName = POA_Done.TrilAcctName
        AND TempAcctNDate.OwnerID = POA_Done.OwnerID
        AND TempAcctNDate.HasCOD_Terms = POA_Done.HasCOD_Terms
LEFT JOIN
        (SELECT COUNT(POA_Num) AS CountOfPartialPOA_Num, 
                TrilAcctName, 
                HasCOD_Terms,
                IIf(OwnerID <> 'BRANCH' AND OwnerID <> 'None', 'SAC', OwnerID) AS OwnerID,
                CONVERT(DATE, EndDate) AS PartialDate, 
                SUM(CurrPOA_Amt*-1) AS SumOfPartialPOA_Amt
           FROM POA_BasicReporting
          WHERE CurrStatus = 'Partial'
          GROUP BY TrilAcctName, 
                HasCOD_Terms, 
                CONVERT(date, EndDate), 
                IIf(OwnerID <> 'BRANCH' AND OwnerID <> 'None', 'SAC', OwnerID)
        ) AS POA_Partial
ON TempAcctNDate.CombinedDate = POA_Partial.PartialDate 
        AND TempAcctNDate.TrilAcctName = POA_Partial.TrilAcctName
        AND TempAcctNDate.OwnerID = POA_Partial.OwnerID
        AND TempAcctNDate.HasCOD_Terms = POA_Partial.HasCOD_Terms

--GO