USE [SharedServices]
GO

CREATE VIEW [dbo].[SummaryOfOpenPOAsByLogin]
AS

SELECT
  AllAccounts.TrilAcctName,
  CountOfOpenPOA_Num,
  SumOfOpenOrigPOA_Amt,
  SumOfOpenAR_Bal,
  SumOfOpenCurrPOA_Amt
FROM
  (SELECT DISTINCT
    TrilAcctName
  FROM dbo.POA_BasicReporting
    )
AS AllAccounts

  LEFT JOIN

  (SELECT
    COUNT(POA_Num) AS CountOfOpenPOA_Num,
    TrilAcctName,
    SUM(OrigPOA_Amt) AS SumOfOpenOrigPOA_Amt,
    SUM(AR_Bal) AS SumOfOpenAR_Bal,
    SUM(CurrPOA_Amt) AS SumOfOpenCurrPOA_Amt
  FROM dbo.POA_BasicReporting
  WHERE
        (CurrStatus NOT IN('Done','Partial'))
    AND (AR_GL_Num <> '1310')
  GROUP BY 
        TrilAcctName 
    )
AS OpenPOA
  ON AllAccounts.TrilAcctName = OpenPOA.TrilAcctName