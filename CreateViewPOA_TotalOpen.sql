USE [SharedServices]
GO

DROP VIEW [dbo].[POA_TotalOpen]
GO

CREATE VIEW [dbo].[POA_TotalOpen]
AS
SELECT COUNT([INVOICE]) AS CountOfOpenPOAs,
    SUM([POA BAL]) AS SumOfCurrPOA_BAL,
    [DATE]
FROM [dbo].[POA_ZOAP]

WHERE [STATUS] NOT IN('Done') AND [AR_GL_NUM] <> '1310'
GROUP BY [DATE]
GO