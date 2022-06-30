USE [SharedServices]
GO

DROP VIEW [dbo].[POA_CreatedPerDay]
GO

CREATE VIEW [dbo].[POA_CreatedPerDay]
AS
SELECT COUNT([INVOICE]) AS CountOfPOAsCreated,
      SUM([POA BAL]) AS SumOfCurrPOA_Bal,
      [DATE]
FROM [dbo].[POA_ZOAP]
WHERE AR_GL_Num <> '1310'
GROUP BY [DATE]

GO