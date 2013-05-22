IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_CreateNewRequest]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_CreateNewRequest]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_CreateNewRequest
	@ExternalRequestID	varchar(50),-- CDR group's request ID
	@Source varchar(50),			-- Source of the request (either 'CDR' or 'ASPEN')
	@RequestType varchar(50),		-- 'Export', 'Remove', 'Full Load', or 'Hotfix'
	@PublicationTarget	varchar(20),-- 'GateKeeper', 'Preview' or 'Live'
	@Description varchar(1000),		-- Description of the request
	@Status varchar(50),			-- 'Receiving'
	@DTDVersion varchar(10),		-- DTD version number
	@DataType varchar(50),			-- Always 'XML'
	@UpdateUserID varchar(50),		-- User submitting the request
	@RequestID	int OUTPUT,
	@Status_Code int OUTPUT,
	@Status_Text varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = -1000	-- Default to an error condition
		SET @Status_Text = 'OK'


		-- Check for existing open requests.
		DECLARE @Open_Record varchar(50)
		Set @Open_Record = (select top 1 externalRequestID from request where status = 'Receiving')
		If( @Open_Record is not Null )
		BEGIN
			SET @Status_Code = -4
			RAISERROR('Request ID (%s) is already open.', 11, 2, @Open_Record )
		END

		-- Check for duplicate external request IDs
		Declare @Row_Exists int
		Set @Row_Exists = (select count(*) from request
							where ExternalRequestID = @ExternalRequestID and
							source = @Source)
		If( @Row_Exists <> 0 )
		BEGIN
			SET @Status_Code = -2
			RAISERROR('External Request ID (%s) already exists.', 11, 2, @ExternalRequestID )
		END

		insert into request(ExternalRequestID,
							Source,
							RequestType,
							PublicationTarget,
							Description,
							Status,
							DTDVersion,
							DataType,
							UpdateUserID)
		values( @ExternalRequestID,
				@Source,
				@RequestType,
				@PublicationTarget,
				@Description,
				@Status,
				@DTDVersion,
				@DataType,
				@UpdateUserID)

		SET @RequestID = SCOPE_IDENTITY()

		-- If we got here, then everything's OK.
		SET @Status_Code = 0

		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		-- @Status_Code should be set before raising the error.
		SET @Status_Text = ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_CreateNewRequest] TO [gatekeeper_role]
GO
