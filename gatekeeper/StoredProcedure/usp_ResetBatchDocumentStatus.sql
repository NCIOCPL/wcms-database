IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_ResetBatchDocumentStatus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_ResetBatchDocumentStatus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_ResetBatchDocumentStatus
	@BatchID	int,
	@Status_Code int OUTPUT,
	@Status_Text varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

	while @@rowcount <> 0	
		begin
			--set rowcount 5000
			update top(5000) requestData
				set Status = 'OK',
					DependencyStatus = 'OK'
			where RequestDataID in
				(select RequestDataID from BatchRequestData where batchID = @BatchID)
						and (status <> 'OK' or dependencystatus <> 'OK')
		end


		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Exception thrown in usp_ResetBatchDocumentStatus ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_ResetBatchDocumentStatus] TO [gatekeeper_role]
GO
