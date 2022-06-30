USE [SharedServices]
GO

DROP VIEW [dbo].[AR_DailyWorkSummary]
GO

CREATE VIEW [dbo].[AR_DailyWorkSummary]
AS

SELECT FullName, SUM(AR_Work) AS CountOfDailyAR_Work, AR_DATE
FROM

    (   SELECT
            COALESCE([FullName],'BRANCH') AS FullName,
            COUNT(INVOICE_NUM) AS AR_Work,
            CAST(COALESCE([END_DATE],[UPDATE_DATE],[START_DATE],[INSERT_DATE]) AS Date) AS AR_DATE
        FROM UNST_ZNST
            LEFT OUTER JOIN POA_Associates
            ON UNST_ZNST.[OWNER] = POA_Associates.UserID
        WHERE [STATUS] NOT IN('Started','None')
        GROUP BY [FullName], CAST(COALESCE([END_DATE],[UPDATE_DATE],[START_DATE],[INSERT_DATE]) AS Date)
    UNION
        SELECT
            COALESCE([FullName],'BRANCH') AS FullName,
            COUNT(INVOICE) AS AR_Work,
            CAST(COALESCE([END_DATE],[UPDATE_DATE],[START_DATE],[INSERT_DATE]) AS Date) AS AR_DATE
        FROM POA_ZOAP
            LEFT OUTER JOIN POA_Associates
            ON POA_ZOAP.[OWNER] = POA_Associates.UserID
        WHERE [STATUS] NOT IN('Started','None')
        GROUP BY [FullName], CAST(COALESCE([END_DATE],[UPDATE_DATE],[START_DATE],[INSERT_DATE]) AS Date)
    UNION
        SELECT
            FullName,
            COUNT([POANum]) AS AR_Work,
            CONVERT(date,[PendingDate]) AS AR_DATE
        FROM POA_PendingLog
            LEFT OUTER JOIN POA_Associates
            ON POA_PendingLog.OwnerID = POA_Associates.UserID
        GROUP BY FullName, CONVERT(date,[PendingDate])
    UNION
        SELECT
            FullName,
            COUNT([Inv_Num]) AS AR_Work,
            CONVERT(date,[PendingDate]) AS AR_DATE
        FROM UNST_PendingLog
            LEFT OUTER JOIN POA_Associates
            ON UNST_PendingLog.OwnerID = POA_Associates.UserID
        GROUP BY FullName, CONVERT(date,[PendingDate])        
	) UnionAliasHere
GROUP BY FullName, AR_DATE