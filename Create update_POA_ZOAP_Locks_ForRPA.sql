USE [SharedServices]
GO

DROP PROCEDURE [dbo].[update_POA_ZOAP_Locks_ForRPA]
GO
/****** Object:  StoredProcedure [dbo].[update_POA_ZOAP_Locks_ForRPA]    Script Date: 7/9/2019 9:09:42 AM ******/

-- =============================================
-- Author:		<Aaron Lawrence>
-- Create date: <5/2/19>
-- Description:	<This Stored Procedure will select and update POA records in table POA_ZOAP for a RPA to use in View POA_ZOAP-BotWorkCheckedOut>
-- =============================================
CREATE PROCEDURE [dbo].[update_POA_ZOAP_Locks_ForRPA] (@RowCount int, @UserID varchar(50))

	-- Add the parameters for the stored procedure here
	-- No Parameters currently
WITH EXECUTE AS OWNER
AS
BEGIN
	-- Declare variables here
	-- None to declare

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

	-- Procedure statements here
	-- Used Transaction to Rollback if something goes wrong
	-- Used Try-Catch Block
	-- Set for the allowance of transaction to abort
	SET XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRANSACTION;
			-- Temporary Common Table Expression for the update step later
			WITH CTE AS
			(	-- There probably should be a parameter here to pass how many records to select for the update
				SELECT TOP (@RowCount) * 
				FROM 
				(
					SELECT * 
					FROM [SharedServices].[dbo].[POA_ZOAP]
					WHERE
					(  
						(	
							-- Exception Path
							-- Some of these are redundant, consider reducing
							[POA COMMENTS FUT PAST] NOT LIKE '%REMIT%' 
							AND [POA COMMENTS FUT PAST] NOT LIKE '%WILL POST%' 
							AND [POA COMMENTS FUT PAST] NOT LIKE '%WILL APPLY%'
							AND [POA COMMENTS FUT PAST] NOT LIKE '%CHECK FOLDER%'
							AND [POA COMMENTS FUT PAST] NOT LIKE '%BACK-UP%'
							AND [POA COMMENTS FUT PAST] NOT LIKE '%MOVE%'
							AND [POA COMMENTS FUT PAST] NOT LIKE '%TRANSFER%'
							AND [POA COMMENTS FUT PAST] NOT LIKE '%BALANCE LESS%'
							AND [POA COMMENTS FUT PAST] NOT LIKE '%LESS%'
							AND [POA COMMENTS FUT PAST] NOT LIKE '%MAIN JOBS%'
							AND [POA COMMENTS FUT PAST] NOT LIKE '%BID%'
							AND [POA COMMENTS FUT PAST] NOT LIKE '%NET%'
							AND [POA COMMENTS FUT PAST] <> 'BRANCH'
							AND [POA COMMENTS FUT PAST] IS NOT NULL
							AND [POA COMMENTS FUT PAST] NOT LIKE '%[B][0-9]%'
							AND [POA COMMENTS FUT PAST] NOT LIKE '%[CA][0-9]%'
							AND [POA COMMENTS FUT PAST] NOT LIKE '%[CS][0-9]%'
							AND [POA COMMENTS FUT PAST] NOT LIKE '%[CT][0-9]%'
							AND [POA COMMENTS FUT PAST] NOT LIKE '%[CN][0-9]%'
							AND [POA COMMENTS FUT PAST] NOT LIKE '%[CW][0-9]%'
							AND TERMS <> 'COD'
							AND ([POA BAL] <> [AR BAL NC] AND  [AR BAL NC] <> [ORIG POA AMT])
							AND LEN([POA COMMENTS FUT PAST]) > 4
						)
						AND
						(
							( -- Happy Path 1
								[AR BAL NC] = 0
							)
							OR
							( -- Happy Path 2
								[POA COMMENTS FUT PAST] LIKE '%PAID ON ACCOUNT%'
								OR [POA COMMENTS FUT PAST] LIKE '%BAL FWD%'
								OR [POA COMMENTS FUT PAST] LIKE '%BALANCE FORWARD%'
								OR [POA COMMENTS FUT PAST] LIKE '%OLD INVOICES%'
								OR [POA COMMENTS FUT PAST] LIKE '%OLDEST INVOICES%'
								OR [POA COMMENTS FUT PAST] LIKE '%CURRENT%'
								OR [POA COMMENTS FUT PAST] LIKE '%PAST INVOICES%'
								OR [POA COMMENTS FUT PAST] LIKE '%TO PAST%'
								OR [POA COMMENTS FUT PAST] LIKE '%TO ACCT%'
								OR [POA COMMENTS FUT PAST] LIKE '%TO ACCOUNT%'
								OR [POA COMMENTS FUT PAST] LIKE '%PAY OFF BALANCE%'
								OR [POA COMMENTS FUT PAST] LIKE '%PAY BALANCE%'
								OR [POA COMMENTS FUT PAST] LIKE '%PAST DUE%'
								OR [POA COMMENTS FUT PAST] LIKE '%APPLY TO BALANCE%'
								OR [POA COMMENTS FUT PAST] LIKE '%PAYMENT%'
							)
							OR
							( -- Happy Path 3 which is just the exception path again
								[POA COMMENTS FUT PAST] NOT LIKE '%REMIT%' 
								AND [POA COMMENTS FUT PAST] NOT LIKE '%WILL POST%' 
								AND [POA COMMENTS FUT PAST] NOT LIKE '%WILL APPLY%'
								AND [POA COMMENTS FUT PAST] NOT LIKE '%CHECK FOLDER%'
								AND [POA COMMENTS FUT PAST] NOT LIKE '%BACK-UP%'
								AND [POA COMMENTS FUT PAST] NOT LIKE '%MOVE%'
								AND [POA COMMENTS FUT PAST] NOT LIKE '%TRANSFER%'
								AND [POA COMMENTS FUT PAST] NOT LIKE '%BALANCE LESS%'
								AND [POA COMMENTS FUT PAST] NOT LIKE '%LESS%'
								AND [POA COMMENTS FUT PAST] NOT LIKE '%MAIN JOBS%'
								AND [POA COMMENTS FUT PAST] NOT LIKE '%BID%'
								AND [POA COMMENTS FUT PAST] NOT LIKE '%NET%'
								AND [POA COMMENTS FUT PAST] <> 'BRANCH'
								AND [POA COMMENTS FUT PAST] IS NOT NULL
								AND [POA COMMENTS FUT PAST] NOT LIKE '%[B][0-9]%'
								AND [POA COMMENTS FUT PAST] NOT LIKE '%[CA][0-9]%'
								AND [POA COMMENTS FUT PAST] NOT LIKE '%[CS][0-9]%'
								AND [POA COMMENTS FUT PAST] NOT LIKE '%[CT][0-9]%'
								AND [POA COMMENTS FUT PAST] NOT LIKE '%[CN][0-9]%'
								AND [POA COMMENTS FUT PAST] NOT LIKE '%[CW][0-9]%'
								AND TERMS <> 'COD'
								AND ([POA BAL] <> [AR BAL NC] AND  [AR BAL NC] <> [ORIG POA AMT])
								AND LEN([POA COMMENTS FUT PAST]) > 4
							)
						)
					)
					AND
					(   -- Excluding POA records that are currently checked out, done, partial and set for pending
						CHECKED_OUT = 0 
						AND [STATUS] NOT IN('Done','Partial') 
						AND PENDING = 0 
					)
					AND
					(	--Only get work for ACCOUNT that AR works
						ACCOUNT IN(SELECT [TrilogieAcctName] FROM [dbo].[POA_BranchAccountInfo] WHERE CloseDate IS Null AND BotWork = 1)
					)
					AND
					NOT
					(
						ACCOUNT = 'DIST' AND [CUST#] = 180177
					)
				) AS RPA
			ORDER BY [DATE] DESC
			)
			/* Update the selected records above to be checked_out, owned by the bot account, status to Started from a None and Started state, update_date to current datetime and start_date to current datetime only if null */ 
			UPDATE CTE SET CHECKED_OUT = 1, [OWNER] = @UserID, [STATUS] = 'Started', UPDATE_DATE = getdate(), [START_DATE] = ISNULL([START_DATE], getdate()) 
			-- Should also consider a parameter to pass OWNER ID
		COMMIT TRANSACTION;
		GOTO DONE
	END TRY
	BEGIN CATCH
		EXECUTE usp_GetErrorInfo;

		IF (XACT_STATE()) <> 0  
		BEGIN  
			PRINT 'The transaction is in an uncommittable state.' +  
				  ' Rolling back transaction.'  
			ROLLBACK TRANSACTION;  
		END;
		GOTO FAIL
	END CATCH;

	DONE:
		RETURN @@ROWCOUNT

	FAIL:
		RETURN -1
END

GO

GRANT EXECUTE ON OBJECT::[dbo].[update_POA_ZOAP_Locks_ForRPA]
	TO [DS\FEI-SSC-AR Users] 
GO