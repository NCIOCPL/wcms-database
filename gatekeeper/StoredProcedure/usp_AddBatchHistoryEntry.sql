IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_AddBatchHistoryEntry]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_AddBatchHistoryEntry]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_AddBatchHistoryEntry
	@BatchID		int,
	@UserName		varchar(50),
	@Entry			varchar(max),
	@Status_Code	int OUTPUT,
	@Status_Text	varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		insert into dbo.BatchHistory
				(BatchID, UserName, Entry, EntryDateTime)
		values	(@BatchID, @UserName, @Entry, GETDATE() )


		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Exception thrown in usp_AddBatchHistoryEntry ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_AddBatchHistoryEntry] TO [gatekeeper_role]
GO
