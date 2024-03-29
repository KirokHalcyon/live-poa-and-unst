USE [SharedServices]
GO

DROP PROCEDURE [dbo].[update_UNST_ZNST_NotDoneWException_ForRPA]
GO
/****** Object:  StoredProcedure [dbo].[update_UNST_ZNST_NotDoneWException_ForRPA]    Script Date: 7/9/2019 9:09:53 AM ******/

-- =============================================
-- Author:		<Aaron Lawrence>
-- Create date: <6/18/19>
-- Description:	<This Stored Procedure will update a single UNST record to be reverted back to a Started state, not checked out and given a new update_date timestamp to put it back into the work flow>
-- =============================================
CREATE PROCEDURE [dbo].[update_UNST_ZNST_NotDoneWException_ForRPA] (@Acct varchar(50), @Inv_Num varchar(50), @UserID varchar(50), @ExceptType varchar(50))
WITH EXECUTE AS OWNER
AS
BEGIN
	-- Variables for the stored procedure
	DECLARE @strInv_Num varchar(50),
			@rtrnInv_Num varchar(50),
			@chkdoutBit bit,
			@rtrnUserID varchar(50),
			@strAcct varchar(50)
	
	-- Test if passed parameter is null
	IF @Inv_Num IS NULL
		BEGIN
			SELECT 'NO UPDATE TO UNST_ZNST' AS 'Inv Number parameter was Null';
			GOTO FAIL
		END 
	IF @Acct IS NULL
		BEGIN
			SELECT 'NO UPDATE TO UNST_ZNST' AS 'Acct parameter was Null';
			GOTO FAIL
		END

	IF @ExceptType IS NULL
		BEGIN
			SELECT 'NO UPDATE TO UNST_ZNST' AS 'ExceptType parameter was Null';
			GOTO FAIL
		END

	SET @strInv_Num = @Inv_Num;
	SET @strAcct = @Acct;

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

	-- Test that the Inv Number passed can be found
	SELECT @rtrnInv_Num = INVOICE_NUM, @chkdoutBit = CHECKED_OUT, @rtrnUserID = [OWNER]
	FROM [dbo].[UNST_ZNST]
	WHERE INVOICE_NUM = @strInv_Num AND ACCOUNT = @strAcct;

	IF @rtrnInv_Num IS NULL
		BEGIN
			SELECT 'NO UPDATE TO UNST_ZNST' AS 'Inv_Num and Acct combination that was passed to this procedure could not be found in UNST_ZNST table';
			GOTO FAIL
		END

	-- Test that the Inv Number hasn't been unlocked by other means

	IF @chkdoutBit = 0
		BEGIN
			SELECT 'NO UPDATE TO UNST_ZNST' AS 'Inv_Num and Acct combination that was passed to this procedure was already checked back in by a separate process';
			GOTO FAIL
		END

	-- Test that the Inv Number isn't owned by someone else

	--IF @UserID <> @rtrnUserID
	--	BEGIN
	--		SELECT 'NO UPDATE TO UNST_ZNST' AS 'Inv_Num and Acct combination that was passed to this procedure is checked out by someone else';
	--		GOTO FAIL
	--	END

    -- Procedure statements here
	-- Used Transaction to Rollback if something goes wrong
	-- Used Try-Catch Block
	-- Set for the allowance of transaction to abort
	SET XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRANSACTION;
			WITH CTE AS
			(
					SELECT *
					FROM [SharedServices].[dbo].[UNST_ZNST]
					WHERE
					(
						INVOICE_NUM = @strInv_Num AND ACCOUNT = @strAcct
					)
			)
			-- Update passed Inv Num to be free of Checked_Out Lock, Set Pending = 0, STATUS to @ExceptType and UPDATE_DATE to Now
			UPDATE CTE SET CHECKED_OUT = 0, [OWNER] = @UserID, PENDING = 0, [STATUS] = @ExceptType, UPDATE_DATE = GetDate()
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

GRANT EXECUTE ON OBJECT::[dbo].[update_UNST_ZNST_NotDoneWException_ForRPA]
	TO [DS\FEI-SSC-AR Users] 
GO