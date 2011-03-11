IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetRequestByID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GetRequestByID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_GetRequestByID
	@RequestID	int,
	@Status_Code int OUTPUT,
	@Status_Text	varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		Declare @ActualDocCount int
		Set @ActualDocCount = (select count(*) from requestData where requestID = @RequestID)

		select RequestID, ExternalRequestID, RequestType, Description, Status, Source, DTDVersion,
			ExpectedDocCount, @ActualDocCount ActualDocCount, DataType, InitiateDate, CompleteReceivedTime, 
			PublicationTarget, UpdateDate, UpdateUserID,
				(select max(PacketNumber) from dbo.RequestData where requestID = @RequestID) MaxPacketNumber
		from request 
		where requestID = @RequestID

		IF( @@ROWCOUNT < 1 )
		BEGIN
			SET @Status_Code = -1
			SET @Status_Text = 'usp_GetRequestByID -- No match found for Request ID = ' + CAST(@RequestID AS varchar)
		END

		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Exception thrown in usp_GetRequestByID ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_GetRequestByID] TO [gatekeeper_role]
GO
