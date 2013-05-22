IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetDocumentStatusMap]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GetDocumentStatusMap]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_GetDocumentStatusMap
	@RequestID int,
	@Status_Code int OUTPUT,
	@Status_Text varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		select requestDataID, Status, DependencyStatus
		from requestData
		where requestID = @RequestID

		IF( @@ROWCOUNT < 1 )
		BEGIN
			Set @Status_Code = 1
			Set @Status_Text = 'No match found for RequestID = ' + CAST(@RequestID AS varchar)
		END

		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Error in usp_GetDocumentStatusMap: ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_GetDocumentStatusMap] TO [gatekeeper_role]
GO
