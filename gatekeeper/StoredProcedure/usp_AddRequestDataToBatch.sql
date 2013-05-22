IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_AddRequestDataToBatch]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_AddRequestDataToBatch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_AddRequestDataToBatch
	@BatchID	int,
	@RequestDataIDs varchar(4000),
	@Status_Code int OUTPUT,
	@Status_Text varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		Declare @Check_ID int

		-- Check for valid BatchID
		Set @Check_ID = (select BatchID from batch where BatchID = @BatchID)

		IF( @Check_ID is null )
		BEGIN
			RAISERROR('usp_AddRequestDataToBatch: No record found for @BatchID = %d',
					11, 1, @BatchID)
		END

		-- Get the RequestID
		Declare @RequestDataIntIDS TABLE(item BigInt)
		Declare @FirstDataID int
		Declare @RequestID int

		Insert into @RequestDataIntIDS(item)
		select item from dbo.udf_ListToBigInt(@RequestDataIDs, ',')

		Set @FirstDataID = (select top 1 item from @RequestDataIntIDS)
		Set @RequestID = (select top 1 requestID from requestData where requestDataID = @FirstDataID)

		-- Everything's OK, proceed with the insert
		insert into BatchRequestData(BatchID, RequestDataID, RequestID)
		Select @BatchID, item, @RequestID from @RequestDataIntIDS

		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Error in usp_AddRequestDataToBatch: ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_AddRequestDataToBatch] TO [gatekeeper_role]
GO
