IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetRequestStatus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GetRequestStatus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_GetRequestStatus
	@RequestID int,
	@Status varchar(50) OUTPUT,
	@Status_Code int OUTPUT,
	@Status_Text	varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		SET @Status = (select status from request where requestID = @RequestID)

		IF( @Status is Null )
		BEGIN
			SET @Status_Code = -1
			SET @Status_Text = 'Request Not Found. @RequestID=' + CAST(@RequestID as varchar)
		END

		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Exception thrown in usp_GetRequestStatus ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_GetRequestStatus] TO [gatekeeper_role]
GO
