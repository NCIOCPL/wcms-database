IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetRequestByExternalID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GetRequestByExternalID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_GetRequestByExternalID
	@ExternalRequestID	varchar(50),
	@Source varchar(50),				-- Source of the request (e.g. 'CDR')
	@Status_Code int OUTPUT,
	@Status_Text varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		-- Look up the request ID and call usp_GetRequestByID
		DECLARE @RequestID int
		Set @RequestID = (select RequestID from request
							where ExternalRequestID = @ExternalRequestID and Source = @Source)

		IF( @RequestID is not Null and @@ROWCOUNT = 1 )
		BEGIN
			DECLARE @RC int
			EXECUTE @RC = usp_GetRequestByID @RequestID, @Status_Code output, @Status_Text output
			if( @RC <> 0 )
				RAISERROR( @Status_Text, 11, 1 )
		END
		ELSE
		BEGIN
			SET @Status_Code = -1
			SET @Status_Text = 'usp_GetRequestByExternalID -- No match found for @ExternalRequestID = ' + CAST(@ExternalRequestID AS varchar)
		END


		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Exception thrown in usp_InsertRequestData ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_GetRequestByExternalID] TO [gatekeeper_role]
GO
