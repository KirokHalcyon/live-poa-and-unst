USE [SharedServices]
GO

DROP VIEW [dbo].[UNST_CreatedPerDay]
GO

CREATE VIEW [dbo].[UNST_CreatedPerDay]
AS
SELECT COUNT([INVOICE_NUM]) As CountofUNST_Created
      ,FORMAT(COALESCE([PROCESS_DATE], [INSERT_DATE]), 'yyyy-MM-dd') AS UNST_DATE
FROM [dbo].[UNST_ZNST]
GROUP BY FORMAT(COALESCE([PROCESS_DATE], [INSERT_DATE]), 'yyyy-MM-dd')

GO
