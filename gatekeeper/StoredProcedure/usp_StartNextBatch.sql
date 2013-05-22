IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_StartNextBatch]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_StartNextBatch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_StartNextBatch
	@Status_Code int OUTPUT,
	@Status_Text	varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		DECLARE @System_Status varchar(50)
		Set @System_Status = (select CSValue from dbo.ControlSettings where CSName = 'SystemStatus')

		IF( @System_Status = 'Normal' )
		BEGIN
			-- Find the next available batch ID
			DECLARE @nextBatch int

			SET @nextBatch = (select min(pq.batchID) from dbo.ProcessQueue pq, dbo.Batch b
								where pq.batchID = b.batchID and
								(b.status = 'Queued' or b.status = 'Processing'))

			-- Mark the batch for processing.
			update batch
				set Status = 'Processing'
			where  BatchID = @nextBatch

			select @nextBatch BatchID
		END

		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Exception thrown in usp_StartNextBatch ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_StartNextBatch] TO [gatekeeper_role]
GO
