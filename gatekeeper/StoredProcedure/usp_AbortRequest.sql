IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_AbortRequest]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_AbortRequest]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_AbortRequest
	@ExternalRequestID	varchar(50),	-- CDR group's request ID
	@Source varchar(50),				-- Source of the request (e.g. 'CDR')
	@UpdateUserID varchar(50),			-- User submitting the request
	@Status_Code int OUTPUT,
	@Status_Text varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		DECLARE @RequestID int
		DECLARE @Current_Status varchar(50)

		select @RequestID = RequestID, @Current_Status = Status
			from dbo.Request
			where ExternalRequestID = @ExternalRequestID and Source = @Source

		-- Don't allow previously accepted requests to be aborted.
		IF( @Current_Status = 'Receiving')
		BEGIN
			update request
			set
				Status = 'Aborted',
				UpdateDate			= GETDATE(),
				UpdateUserID		= @UpdateUserID
			where RequestID = @RequestID
		END
		-- Only report an error if the request was completed normally.
		ELSE IF( @Current_Status = 'DataReceived' )
		BEGIN
			SET @Status_Code = -3
			RAISERROR( 'usp_AbortRequest - Attempt to abort a request which was not open, @ExternalRequestID= %s',
						1, 1, @ExternalRequestID )
		END

		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		SET @Status_Text = ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_AbortRequest] TO [gatekeeper_role]
GO
