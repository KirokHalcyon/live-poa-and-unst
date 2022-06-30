USE [SharedServices]
GO

/****** Object:  View [dbo].[POA_ZOAP-BotWorkCheckedOut]    Script Date: 7/15/2019 1:50:18 PM ******/
DROP VIEW [dbo].[POA_ZOAP-BotWorkCheckedOut]
GO

CREATE VIEW [dbo].[POA_ZOAP-BotWorkCheckedOut]
AS
SELECT        ACCOUNT, CUST#, INVOICE, [POA COMMENTS FUT PAST], DATE, [ORIG POA AMT], [AR BAL NC], [POA BAL], TERMS, INSERT_DATE, CHECKED_OUT, [POA WHSE]
FROM            dbo.POA_ZOAP
WHERE        (CHECKED_OUT = 1) AND (OWNER IN ('AAQ6349', 'SAP0134', 'SAP0140')) AND (PENDING = 0) AND (STATUS NOT IN ('Done', 'Partial'))

GO