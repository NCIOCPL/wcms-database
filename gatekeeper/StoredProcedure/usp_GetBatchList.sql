IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetBatchList]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GetBatchList]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_GetBatchList
	@Filter int,
	@Status_Code int OUTPUT,
	@Status_Text	varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		-- Retrieve all.
		IF( @Filter = 0)
		BEGIN
			select BatchID from ProcessQueue
			order by ProcessQueueID
		END

		-- Active Only (No Complete with Errors)
		ELSE IF( @Filter = 1 )
		BEGIN
			select pq.BatchID
			from ProcessQueue pq, batch b
			where pq.batchID = b.batchID AND
				b.status <> 'CompleteWithErrors'
			order by pq.ProcessQueueID
		END

		-- Errors Only (Complete with Errors)
		ELSE IF( @Filter = 2 )
		BEGIN
			select pq.BatchID
			from ProcessQueue pq, batch b
			where pq.batchID = b.batchID AND
				b.status = 'CompleteWithErrors'
			order by pq.ProcessQueueID
		END
		ELSE
			RAISERROR('usp_GetBatchList: Unknown Filter ID %d', 11, 1, @Filter )

		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Exception thrown in usp_GetBatchList ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_GetBatchList] TO [gatekeeper_role]
GO
