USE [SharedServices]
GO

DROP VIEW [dbo].[POA_ClearedPerDay]
GO

CREATE VIEW [dbo].[POA_ClearedPerDay]
AS
SELECT COUNT([INVOICE]) AS CountOfPOAsCleared
      , SUM([ORIG POA AMT]) AS SumOfOrigPOA_Amt
	, SUM([POA BAL]) AS SumOfCurrPOA_Bal
      , FORMAT([END_DATE], 'yyyy-MM-dd') AS END_DATE
FROM [dbo].[POA_ZOAP]
WHERE [END_DATE] IS NOT NULL AND [STATUS] <> 'Partial'
GROUP BY FORMAT([END_DATE], 'yyyy-MM-dd')

GO