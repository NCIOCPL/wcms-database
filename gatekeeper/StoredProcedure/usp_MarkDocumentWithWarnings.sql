IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_MarkDocumentWithWarnings]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_MarkDocumentWithWarnings]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_MarkDocumentWithWarnings
	@RequestDataID	int,
	@Status_Code int OUTPUT,
	@Status_Text varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		-- Mark the selected document as having warnings, but don't
		-- overwrite an existing Error flag.
		update dbo.RequestData
			set Status = 'Warning'
		where RequestDataID = @RequestDataID
			and Status <> 'Error'

		RETURN 0  --Succesful return 0

	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Exception thrown in usp_MarkDocumentWithWarnings ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_MarkDocumentWithWarnings] TO [gatekeeper_role]
GO
