IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_CreateNewBatch]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_CreateNewBatch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_CreateNewBatch
	@BatchName	varchar(150),
	@UserName varchar(50),
	@PubActions varchar(500),
	@BatchID	int OUTPUT,
	@Status_Code int OUTPUT,
	@Status_Text varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		-- Batch is intially created with Invalid status to prevent it from
		-- being run before all RequestData entries are added.
		insert into batch(BatchName, UserName, Status)
		values(@BatchName, @UserName, 'Invalid')

		SET @BatchID = SCOPE_IDENTITY()

		-- Add batch to the BatchAction table in order to track what publication
		-- actions are needed.
		insert into BatchAction(BatchID, ProcessActionID)
		select @BatchID BatchID, PA.ProcessActionID
		from ProcessAction PA, (select item from dbo.udf_ListToStrings(@PubActions, ',')) ActionList
		where PA.Name = ActionList.Item

		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Exception thrown in usp_CreateNewBatch ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_CreateNewBatch] TO [gatekeeper_role]
GO
