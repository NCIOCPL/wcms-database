IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetBatch]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GetBatch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_GetBatch
	@BatchID	int,
	@Status_Code int OUTPUT,
	@Status_Text	varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		-- Load Batch information
		select BatchID, BatchName, UserName, Status
		from dbo.Batch
		where BatchID = @BatchID

		IF( @@ROWCOUNT < 1 )
		BEGIN
			SET @Status_Code = -1
			SET @Status_Text = 'usp_GetBatch -- No match found for Batch ID = ' + CAST(@BatchID AS varchar)
		END

		-- Load list of RequestData IDs.  No error checking intended. (Allow no-data to be non-fatal.)
		select rd.RequestDataID
		from dbo.RequestData rd, dbo.BatchRequestData brd
		where rd.RequestDataID = brd.RequestDataID and
			brd.BatchID = @BatchID
		order by ActionType	-- ensures Export is processed before Remove

		-- Load list of processing steps.
		select pa.name
		from ProcessAction pa, BatchAction ba
		where pa.ProcessActionID = ba.ProcessActionID and
			ba.BatchID = @BatchID
		order by pa.priority
		

		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Exception thrown in usp_GetBatch ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_GetBatch] TO [gatekeeper_role]
GO
