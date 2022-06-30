USE [SharedServices]
GO

--DROP VIEW [dbo].[UNST_Reporting-Branches]
--GO

CREATE VIEW [dbo].[UNST_Reporting-Branches]
AS
SELECT TempAcctNDate.TrilAcctName, TempAcctNDate.CombinedDate, TempAcctNDate.OwnerID,
    CalendarDim.WeekOfYear, CalendarDim.FiscalWeekOfYear,
    CalendarDim.Month, CalendarDim.FiscalMonth, CalendarDim.MonthName,
    CalendarDim.Quarter, CalendarDim.FiscalQuarter, CalendarDim.QuarterName, CalendarDim.FiscalQuarterName,
    CalendarDim.Year, CalendarDim.FiscalYear,
    CalendarDim.MMYYYY, CalendarDim.FiscalMMYYYY, CalendarDim.MonthYear,
    UNST_Inserted.CountOfUNST_NumInserted, UNST_Inserted.SumOfOrigInvBal,
    UNST_Partial.CountOfPartialUNST_Num, UNST_Partial.SumOfPartialUNST_Amt,
    UNST_Done.CountOfDoneUNST_Num, UNST_Done.SumOfFinalUNST_Amt
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
    (            SELECT UNST_BasicReporting.TrilAcctName,
            IIf(UNST_BasicReporting.OwnerID <> 'BRANCH' AND UNST_BasicReporting.OwnerID <> 'None', 'SAC', UNST_BasicReporting.OwnerID) AS OwnerID,
            CONVERT(date,[InsertDate]) AS CombinedDate
        FROM UNST_BasicReporting
        GROUP BY UNST_BasicReporting.TrilAcctName, 
                        CONVERT(date,[InsertDate]), 
                        IIf(UNST_BasicReporting.OwnerID <> 'BRANCH' AND UNST_BasicReporting.OwnerID <> 'None', 'SAC', UNST_BasicReporting.OwnerID)
    UNION

        SELECT UNST_BasicReporting.TrilAcctName,
            IIf(UNST_BasicReporting.OwnerID <> 'BRANCH' AND UNST_BasicReporting.OwnerID <> 'None', 'SAC', UNST_BasicReporting.OwnerID) AS OwnerID,
            CONVERT(DATE, EndDate) AS CombinedDate
        FROM UNST_BasicReporting
        GROUP BY UNST_BasicReporting.TrilAcctName, 
                        CONVERT(date, EndDate), 
                        IIf(UNST_BasicReporting.OwnerID <> 'BRANCH' AND UNST_BasicReporting.OwnerID <> 'None', 'SAC', UNST_BasicReporting.OwnerID)
                ) AS TempAcctNDate
    ON CalendarDim.[Date] = TempAcctNDate.CombinedDate
    LEFT JOIN
    (SELECT COUNT(InvNum) AS CountOfUNST_NumInserted,
        UNST_BasicReporting.TrilAcctName,
        IIf(UNST_BasicReporting.OwnerID <> 'BRANCH' AND UNST_BasicReporting.OwnerID <> 'None', 'SAC', UNST_BasicReporting.OwnerID) AS OwnerID,
        CONVERT(date,[InsertDate]) AS InsertDate,
        SUM(OrigInvBal) AS SumOfOrigInvBal
    FROM UNST_BasicReporting
    GROUP BY UNST_BasicReporting.TrilAcctName, 
                CONVERT(date,[InsertDate]), 
                IIf(UNST_BasicReporting.OwnerID <> 'BRANCH' AND UNST_BasicReporting.OwnerID <> 'None', 'SAC', UNST_BasicReporting.OwnerID)
        ) AS UNST_Inserted
    ON TempAcctNDate.CombinedDate = UNST_Inserted.InsertDate
        AND TempAcctNDate.TrilAcctName = UNST_Inserted.TrilAcctName
        AND TempAcctNDate.OwnerID = UNST_Inserted.OwnerID
    LEFT JOIN
    (SELECT COUNT(InvNum) AS CountOfDoneUNST_Num,
        UNST_BasicReporting.TrilAcctName,
        IIf(UNST_BasicReporting.OwnerID <> 'BRANCH' AND UNST_BasicReporting.OwnerID <> 'None', 'SAC', UNST_BasicReporting.OwnerID) AS OwnerID,
        CONVERT(DATE, EndDate) AS CompletedDate,
        SUM(OrigInvBal*-1) AS SumOfFinalUNST_Amt
    FROM UNST_BasicReporting
    WHERE CurrStatus = 'Done'
    GROUP BY UNST_BasicReporting.TrilAcctName, 
                CONVERT(date, EndDate), 
                IIf(UNST_BasicReporting.OwnerID <> 'BRANCH' AND UNST_BasicReporting.OwnerID <> 'None', 'SAC', UNST_BasicReporting.OwnerID)
        ) AS UNST_Done
    ON TempAcctNDate.CombinedDate = UNST_Done.CompletedDate
        AND TempAcctNDate.TrilAcctName = UNST_Done.TrilAcctName
        AND TempAcctNDate.OwnerID = UNST_Done.OwnerID
    LEFT JOIN
    (SELECT COUNT(InvNum) AS CountOfPartialUNST_Num,
        TrilAcctName,
        IIf(OwnerID <> 'BRANCH' AND OwnerID <> 'None', 'SAC', OwnerID) AS OwnerID,
        CONVERT(DATE, EndDate) AS PartialDate,
        SUM((OrigInvBal-CurrInvBal)*-1) AS SumOfPartialUNST_Amt
    FROM UNST_BasicReporting
    WHERE CurrStatus = 'Partial'
    GROUP BY TrilAcctName, 
                CONVERT(date, EndDate), 
                IIf(OwnerID <> 'BRANCH' AND OwnerID <> 'None', 'SAC', OwnerID)
        ) AS UNST_Partial
    ON TempAcctNDate.CombinedDate = UNST_Partial.PartialDate
        AND TempAcctNDate.TrilAcctName = UNST_Partial.TrilAcctName
        AND TempAcctNDate.OwnerID = UNST_Partial.OwnerID

--GO