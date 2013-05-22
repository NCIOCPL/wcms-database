IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_AddRequestToBatch]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_AddRequestToBatch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_AddRequestToBatch
	@BatchID	int,
	@RequestID int,
	@Status_Code int OUTPUT,
	@Status_Text varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		Declare @Check_ID int

		-- Check for valid RequestID
		Set @Check_ID = (select RequestID from request where RequestID = @RequestID)
		IF( @Check_ID is null )
		BEGIN
			RAISERROR('usp_AddRequestToBatch: No record found for @RequestID = %d',
					11, 1, @RequestID)
		END

		-- Check for valid BatchID
		Set @Check_ID = (select BatchID from batch where BatchID = @BatchID)
		IF( @Check_ID is null )
		BEGIN
			RAISERROR('usp_AddRequestToBatch: No record found for @BatchID = %d',
					11, 2, @BatchID)
		END

		-- Everything's OK, proceed with the insert
		insert into BatchRequestData(BatchID, RequestDataID, requestID)
		select @BatchID BatchID, requestDataID, @RequestID RequestID
		from requestData
		where requestID = @RequestID

		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Error in usp_AddRequestToBatch: ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_AddRequestToBatch] TO [gatekeeper_role]
GO
