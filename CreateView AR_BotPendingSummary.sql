USE [SharedServices]
GO

--DROP VIEW [dbo].[AR_BotPendingSummary]
--GO

CREATE VIEW [dbo].[AR_BotPendingSummary]
AS

SELECT FullName, SUM(AR_Work) AS CountOfBotPending, AR_DATE
FROM
(
    SELECT
        FullName,
        COUNT([POANum]) AS AR_Work,
        CONVERT(date,[PendingDate]) AS AR_DATE
    FROM POA_PendingLog
        LEFT OUTER JOIN POA_Associates
        ON POA_PendingLog.OwnerID = POA_Associates.UserID
    WHERE POA_PendingLog.OwnerID IN('ABB3227','ABB4625')
    GROUP BY FullName, CONVERT(date,[PendingDate])
UNION
    SELECT
        FullName,
        COUNT([Inv_Num]) AS AR_Work,
        CONVERT(date,[PendingDate]) AS AR_DATE
    FROM UNST_PendingLog
        LEFT OUTER JOIN POA_Associates
        ON UNST_PendingLog.OwnerID = POA_Associates.UserID
        WHERE UNST_PendingLog.OwnerID IN('ABB3227','ABB4625')
    GROUP BY FullName, CONVERT(date,[PendingDate])
) UnionAliasHere
GROUP BY FullName, AR_DATE