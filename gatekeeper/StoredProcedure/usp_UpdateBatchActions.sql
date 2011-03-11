IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_UpdateBatchActions]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_UpdateBatchActions]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_UpdateBatchActions
	@BatchID	int,
	@ActionName	varchar(50),
	@Status_Code int OUTPUT,
	@Status_Text	varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		-- No need for error checking.  SQL will raise an error if the
		-- records don't exist.
		update dbo.BatchAction
			Set CompletionDate = GETDATE()
		where BatchID = @BatchID and
			ProcessActionID =
				(select pa.ProcessActionID from dbo.ProcessAction pa where pa.name = @ActionName)

		IF( @@Rowcount < 1 )
		BEGIN
			SET @Status_Code = -1
			RAISERROR( 'No match found for batch ID %d, action %s.', 11, 1, @BatchID, @ActionName )
		END
		ELSE IF( @@Rowcount > 1 )
		BEGIN
			SET @Status_Code = -3
			RAISERROR( 'Multiple matches found for batch ID %d, action %s.', 11, 2, @BatchID, @ActionName )
		END

		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		SET @Status_Text = ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_UpdateBatchActions] TO [gatekeeper_role]
GO
