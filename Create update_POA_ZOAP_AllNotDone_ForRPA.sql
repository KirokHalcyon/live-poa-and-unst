USE [SharedServices]
GO

DROP PROCEDURE [dbo].[update_POA_ZOAP_AllNotDone_ForRPA]
GO

-- =============================================
-- Author:		<Aaron Lawrence>
-- Create date: <9/17/19>
-- Description:	<This Stored Procedure will update all remaining POA records to be reverted back to a Started state, not checked out and given a new update_date timestamp to put it back into the work flow>
-- =============================================
CREATE PROCEDURE [dbo].[update_POA_ZOAP_AllNotDone_ForRPA] (@UserID varchar(50))
WITH EXECUTE AS OWNER
AS
BEGIN
	-- Variables for the stored procedure
	DECLARE @strUserID varchar(50)
	
	-- Test if passed parameter is null
	IF @UserID IS NULL
		BEGIN
			SELECT 'NO UPDATE TO POA_ZOAP' AS 'UserID parameter was Null';
			GOTO FAIL
		END 

	SET @strUserID = @UserID;

	-- SET NOCOUNT OFF added to allow extra result sets.
	SET NOCOUNT OFF;

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
					FROM [SharedServices].[dbo].[POA_ZOAP]
					WHERE
					(-- Only do this for records it owns, that are currently checkedout by it and not in a status of being Done or Partially Done
						[OWNER] = @strUserID 
                            AND STATUS NOT IN('Done','Partial')
                            AND CHECKED_OUT = 1
					)
			)
			-- Update passed POA Num to be free of Checked_Out Lock, STATUS to 'Started' and UPDATE_DATE to Now
			UPDATE CTE SET CHECKED_OUT = 0, [STATUS] = 'Started', UPDATE_DATE = GetDate()
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

GRANT EXECUTE ON OBJECT::[dbo].[update_POA_ZOAP_AllNotDone_ForRPA]
	TO [DS\FEI-SSC-AR Users] 
GO