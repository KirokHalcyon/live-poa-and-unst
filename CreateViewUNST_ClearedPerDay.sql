USE [SharedServices]
GO

CREATE VIEW [dbo].[UNST_ClearedPerDay]
AS
SELECT COUNT([INVOICE_NUM]) AS CountOfUNST_Cleared
      ,FORMAT([END_DATE], 'yyyy-MM-dd') AS END_DATE
FROM [dbo].[UNST_ZNST]
WHERE [END_DATE] IS NOT NULL AND [STATUS] <> 'Partial'
GROUP BY FORMAT([END_DATE], 'yyyy-MM-dd')
 
GO