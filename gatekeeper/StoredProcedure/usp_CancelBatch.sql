IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_CancelBatch]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_CancelBatch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_CancelBatch
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

		DECLARE @CurrStatus varchar(50)
		SET @CurrStatus = (select status from batch where BatchID = @BatchID)

		if( @CurrStatus = 'Queued' )
		BEGIN
			delete from ProcessQueue
			where BatchID = @BatchID

			update Batch
				Set Status = @Status
			where BatchID = @BatchID
		END
		ELSE
		BEGIN
			SET @Status_Code = 2
			SET @Status_Text = 'usp_CancelBatch: Batch not in a Queued state. @BatchID = ' +
				CAST(@BatchID as varchar(12))
		END

		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Exception thrown in usp_CancelBatch ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_CancelBatch] TO [gatekeeper_role]
GO
