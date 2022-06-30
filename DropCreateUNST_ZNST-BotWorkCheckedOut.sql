USE [SharedServices]
GO

/****** Object:  View [dbo].[UNST_ZNST-BotWorkCheckedOut]    Script Date: 7/15/2019 1:50:24 PM ******/
DROP VIEW [dbo].[UNST_ZNST-BotWorkCheckedOut]
GO

CREATE VIEW [dbo].[UNST_ZNST-BotWorkCheckedOut]
AS
SELECT        WHSE, ACCOUNT, CUST, NAME, BAL, INVOICE_NUM, PY_NUMBER, PY_COMMENT, PY_AMOUNT, SHIP_INSTR1, SHIP_INSTR2, SHIP_INSTR3, SHIP_INSTR4, CRMEMO,
                             (SELECT        COUNT(*) AS Expr1
                               FROM            dbo.CalendarDim
                               WHERE        (Date BETWEEN dbo.UNST_ZNST.PROCESS_DATE AND GETDATE()) AND (IsWeekend = 0) AND (IsHoliday = 0)) AS DAYS_OPEN
FROM            dbo.UNST_ZNST
WHERE        (CHECKED_OUT = 1) AND (OWNER IN ('AAQ6349', 'SAP0134', 'SAP0140')) AND (PENDING = 0) AND (STATUS NOT IN ('Done', 'Partial'))

GO
