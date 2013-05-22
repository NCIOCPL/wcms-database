IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_MarkDocumentWithErrors]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_MarkDocumentWithErrors]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_MarkDocumentWithErrors
	@RequestDataID	int,
	@RequestID	int,
	@GroupID	int,
	@Status_Code int OUTPUT,
	@Status_Text varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		-- Mark the selected document as having errors.
		update dbo.RequestData  with (TABLOCKX)
			set Status = 'Error'
		where RequestDataID = @RequestDataID

		-- Mark the other documents in the group as having an error
		-- in a dependent.
		update dbo.RequestData 
			set DependencyStatus = 'Error'
		where RequestDataID <> @RequestDataID and
			requestID = @RequestID and
			groupID = @GroupID 
		
		RETURN 0  --Succesful return 0

	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Exception thrown in usp_MarkDocumentWithErrors ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_MarkDocumentWithErrors] TO [gatekeeper_role]
GO
