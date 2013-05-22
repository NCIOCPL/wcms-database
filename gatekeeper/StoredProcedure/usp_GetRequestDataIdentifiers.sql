IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetRequestDataIdentifiers]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GetRequestDataIdentifiers]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_GetRequestDataIdentifiers
	@RequestDataID	int,
	@RequestID	int OUTPUT,
	@GroupID	int OUTPUT,
	@Status_Code int OUTPUT,
	@Status_Text	varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		select @requestID = requestID, @groupID = groupID
		from dbo.RequestData where RequestDataID = @RequestDataID

		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Exception thrown in usp_GetRequestDataIdentifiers ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_GetRequestDataIdentifiers] TO [gatekeeper_role]
GO
