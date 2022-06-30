USE [SharedServices]
GO

DROP VIEW [dbo].[POA_POA_TotalOpenNoComments]
GO

CREATE VIEW [dbo].[POA_TotalOpenNoComments]
AS
SELECT Count([POA_Num]) AS CountOfJunkPOAsNotDone
      , CAST([POA_Date] AS Date) AS POA_Date
 	  , Sum([OrigPOA_Amt]) AS SumOfOrigPOA_Amt
      , Sum([CurrPOA_Amt]) AS SumOfCurrPOA_Amt
      , [HasCOD_Terms]
	  , [HasComments]
FROM [dbo].[POA_BasicReporting]
WHERE ([CurrStatus] <> 'Done' AND [AR_GL_Num] <> '1310') AND ([HasComments] <> 1 OR [HasCOD_Terms] = 1)
GROUP BY CAST([POA_Date] AS Date), [HasCOD_Terms], [HasComments]
GO