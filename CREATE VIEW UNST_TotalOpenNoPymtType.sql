USE [SharedServices]
GO

--DROP VIEW [dbo].[UNST_TotalOpenNoPymtType]
--GO

CREATE VIEW [dbo].[UNST_TotalOpenNoPymtType]
AS
SELECT
    TrilAcctName
	  , Count([InvNum]) AS CountOfJunkUNST
	  , Sum([OrigInvBal]) AS SunOfOrigInvBal
      , Sum([CurrInvBal]) AS SumOfCurrInvBal
	  , FORMAT(COALESCE([InvProcDate], [InsertDate]), 'yyyy-MM-dd') AS UNST_DATE
FROM [dbo].[UNST_BasicReporting]
WHERE CurrStatus <> 'Done' AND ([HasPymtNumCMorPA] = 0 OR CustGL_Num NOT IN('1300','1322'))
GROUP BY
	   TrilAcctName
	  ,FORMAT(COALESCE([InvProcDate], [InsertDate]), 'yyyy-MM-dd')
GO