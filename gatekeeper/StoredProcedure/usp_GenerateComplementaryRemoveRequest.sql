
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'usp_GenerateComplementaryRemoveRequest' AND type = 'P') 
   DROP PROCEDURE usp_GenerateComplementaryRemoveRequest
GO

CREATE PROCEDURE [dbo].[usp_GenerateComplementaryRemoveRequest]
	@FullLoadRequestID varchar(50),
	@FullLoadSource			varchar(50),
	@Status_Code int OUTPUT,
	@Status_Text	varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		create table #t (cdrid int primary key)

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		DECLARE @GeneratingSource varchar(25)	-- Source for generated request
		Set @GeneratingSource = 'GateKeeper'

		-- Create semi-duplicate Request Entry
		DECLARE @OriginalRequestID	int
		DECLARE @NewRequestID	int
		DECLARE @ExternalID varchar(50)
		DECLARE @Description varchar(1000)		-- Description of the request
		DECLARE @DTDVersion varchar(10)			-- DTD version number
		DECLARE @DataType varchar(50)			-- Always 'XML'
		DECLARE @UpdateUserID varchar(50)		-- User submitting the request

		select	@OriginalRequestID = requestID,
				@DTDVersion = DTDVersion,
				@DataType = DataType,
				@UpdateUserID = UpdateUserID
		from request where  ExternalRequestID = @FullLoadRequestID and Source = @FullLoadSource

		SET @Description = 'Generated for Request ' + lTrim(str(@OriginalRequestID))

		Declare @MatchCount int
		SET @MatchCount = (select count(*) from Request
							where ExternalRequestID like (lTrim(str(@OriginalRequestID)) + '%'))
		IF( @MatchCount = 0 )
			SET @ExternalID = LTrim(Str(@OriginalRequestID))
		Else
			SET @ExternalID = lTrim(str(@OriginalRequestID)) + ' (' + lTrim(str(@MatchCount)) + ')'

		Exec usp_CreateNewRequest
			@ExternalID,		-- Use Original request's ID as the external ID.
			@GeneratingSource,	-- Source of the request
			'Remove',			-- Request type.
			'GateKeeper',		-- Publication target, Generated request is always manual
			@Description,		-- Description
			'Receiving',		-- Current status
			@DTDVersion,		-- DTD version number
			@DataType,			-- Always 'XML'
			@UpdateUserID,		-- User submitting the request
			@NewRequestID OUTPUT,
			@Status_Code OUTPUT,
			@Status_Text OUTPUT

		

		if( @Status_Code < 0 )
		BEGIN
			RAISERROR( 'Error creating new Request: %s.', 11, 1, @Status_Text )
		END

		insert into #t	
		select cdrid from dbo.requestdata where requestid =  @OriginalRequestID


		declare  @t table(PacketNumber int,
									RequestID int,
									ActionType varchar(50),
									DataSetID int ,
									CDRID int,
									CDRVersion varchar(50),
									Status varchar(50),
									DependencyStatus varchar(50),
									Location varchar(50),
									GroupID int,
									ReceivedDate datetime,
									isArchived bit)

		


		

		insert into @t(PacketNumber,
									RequestID,
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
		select ROW_NUMBER() over (order by a.CDRID) Row,
			@NewRequestID, 'Remove', rd.DataSetID, rd.CDRID, rd.CDRVersion,
			'OK', 'OK', 'GateKeeper', rd.GroupID, GETDATE(), 0
		from dbo.requestdata rd
			inner join
				(	select rd.cdrid, max(rd.requestid) as maxrequestID
					from dbo.RequestData rd inner loop join dbo.cdrdocumentlocation l
						on rd.cdrid = l.cdrid
					where  (rd.requestdataid = l.liverequestdataid or 
							rd.requestdataid = l.previewrequestdataid or 
							rd.requestdataid = l.stagingrequestdataid )
						and rd.cdrid not in (select cdrid from #t)
					group by rd.cdrid) a
			 on rd.cdrid = a.cdrid and rd.requestid = a.maxrequestID



		insert into dbo.RequestData(PacketNumber,
									RequestID,
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
		select * from @t


		-- Mark the request complete
		DECLARE @ExpectedCount int
		set @ExpectedCount = (select count(*) from requestData where requestID = @NewRequestID)

		EXEC usp_CompleteRequest @ExternalID, @GeneratingSource, @UpdateUserID, @ExpectedCount,
			@Status_Code OUTPUT, @Status_Text OUTPUT

		if( @Status_Code < 0 )
		BEGIN
			EXEC usp_AbortRequest @ExternalID, @GeneratingSource, @UpdateUserID
			RAISERROR( 'Error while marking request complete: %s.', 11, 2, @Status_Text )
		END


		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		-- If status code wasn't set for the error, then force a large negative
		-- value so the middle tier will thrown an exception.
		SET @Status_Code = -1000
		SET @Status_Text = ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END
GO


GRANT EXECUTE on usp_GenerateComplementaryRemoveRequest TO Gatekeeper_role
GO

