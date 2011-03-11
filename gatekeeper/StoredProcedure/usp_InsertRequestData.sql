IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_InsertRequestData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_InsertRequestData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_InsertRequestData
	@ExternalRequestID	varchar(50),-- CDR group's ID for the associated request
	@Source varchar(50),			-- Source of the request (e.g. 'CDR')
	@UpdateUserID varchar(50),		-- User submitting the document
	@PacketNumber int,				-- Packet number (e.g. 2 for packet 2 of 50)
	@ActionType	varchar(50),		-- 'Export' or 'Remove'
	@DataSetID	int,				-- Document type from DocumentType table.
	@CDRID int,						-- CDR Document ID
	@CDRVersion	varchar(50),		-- CDR document version number
	@Status varchar(50),			-- 'OK', 'Warning' or 'Error'
	@DependencyStatus varchar(50),	-- 'OK' or 'Error'
	@Location varchar(50),			-- Document's last promotion location ('GateKeeper', 'Staging', 'Preview' or 'Live')
	@GroupID int,					-- Dependency group within the request.
	@DocumentData	nvarchar(max),
	@RequestDataID	int OUTPUT,
	@Status_Code int OUTPUT,
	@Status_Text varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		-- Look up the RequestID
		DECLARE @RequestID int
		DECLARE @RequestStatus varchar(50)

		select @RequestID = RequestID, @RequestStatus = Status
			from dbo.Request
			where ExternalRequestID = @ExternalRequestID and Source = @Source

		-- Abort if record doesn't exist or has duplicates.
		IF( @RequestID is null OR @@ROWCOUNT = 0)
		BEGIN
			SET @Status_Code = -1
			RAISERROR('usp_InsertRequestData: No record found for @ExternalRequestID = %s.',
					11, 1, @ExternalRequestID)
		END

		IF( @@ROWCOUNT > 1)
		BEGIN
			SET @Status_Code = -1
			RAISERROR('usp_InsertRequestData: Multiple records found for @ExternalRequestID = %s.',
					11, 1, @ExternalRequestID)
		END

		-- Don't allow insert into a request which has already been completed.
		IF( @RequestStatus <> 'Receiving' )
		BEGIN
			SET @Status_Code = -3
			RAISERROR('usp_InsertRequestData: Request %s is already closed.',
					11, 2, @ExternalRequestID)
		END

		-- Check for duplicates.
		Declare @PreExistingCount int
		Set @PreExistingCount =
			(select count(*) from requestData
			 where requestID = @RequestID and
				(packetNumber = @PacketNumber OR CDRID = @CDRID))
		IF( @PreExistingCount <> 0 )
		BEGIN
			SET @Status_Code = -2
			RAISERROR('usp_InsertRequestData: Packet %d (CDRID: %d) duplicates one or more existing records.',
					11, 3, @PacketNumber, @CDRID)
		END


		-- Store the RequestData metadata.
		insert into dbo.RequestData(RequestID,
									PacketNumber,
									ActionType,
									DataSetID,
									CDRID,
									CDRVersion,
									Status,
									DependencyStatus,
									Location,
									GroupID,
									ReceivedDate,
									isArchived)
		values( @RequestID,
				@PacketNumber,
				@ActionType,
				@DataSetID,
				@CDRID,
				@CDRVersion,
				@Status,
				@DependencyStatus,
				@Location,
				@GroupID,
				GETDATE(),
				0)

		SET @RequestDataID = SCOPE_IDENTITY()

		-- Store the document data in it's own table.
		insert into dbo.DocumentData(RequestDataID, Data)
		values(@RequestDataID, @DocumentData)

		-- Mark the request as Updated
		update dbo.Request
			set UpdateDate = GETDATE(),
				UpdateUserID = @UpdateUserID
		where RequestID = @RequestID

		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		SET @Status_Text = ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_InsertRequestData] TO [gatekeeper_role]
GO
