IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_CompleteBatchWithErrors]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_CompleteBatchWithErrors]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_CompleteBatchWithErrors
	@BatchID	int,
	@Status	varchar(50),
	@Status_Code int OUTPUT,
	@Status_Text	varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		-- Update the batch status, but do not remove from queue.
		update Batch
			Set Status = @Status
		where BatchID = @BatchID

		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Exception thrown in usp_CompleteBatchWithErrors ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_CompleteBatchWithErrors] TO [gatekeeper_role]
GO
