IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetMostRecentExternalID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GetMostRecentExternalID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_GetMostRecentExternalID
	@RequestSource varchar(50),
	@MostRecentExternalID varchar(50) OUTPUT,
	@Status_Code int OUTPUT,
	@Status_Text	varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		-- Look up external ID of the most recent request.
		SET @MostRecentExternalID = 
				(select ExternalRequestID
				 from dbo.Request
				 where RequestID =
					(select max(requestId) from dbo.Request where source = @RequestSource))

		IF( @MostRecentExternalID is null)
			SET @MostRecentExternalID = 0

		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Exception thrown in usp_GetMostRecentExternalID ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_GetMostRecentExternalID] TO [gatekeeper_role]
GO
