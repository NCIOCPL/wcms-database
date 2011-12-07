USE [Gatekeeper]
GO

/****** Object:  StoredProcedure [dbo].usp_CopyRequestData    Script Date: 12/01/2011 18:15:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].usp_CopyRequestData') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].usp_CopyRequestData
GO

USE [Gatekeeper]
GO

/****** Object:  StoredProcedure [dbo].usp_CopyRequestData    Script Date: 12/01/2011 18:15:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].usp_CopyRequestData
	@RequestDataIDs	varchar(8000),-- CDR group's ID for the associated request
	@RequestID int,				-- Request Id 
	@updateUserID varchar(255), --userid
	@Status_Code int OUTPUT,
	@Status_Text varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON
	
	-- Load Request data ids into a temporary table
		DECLARE @String			VARCHAR(15)
		DECLARE @OutputTable	TABLE ([requestDataId] INT)

		WHILE LEN(@RequestDataIDs) > 0
		BEGIN
			SET @String      = LEFT(@RequestDataIDs, 
									ISNULL(NULLIF(CHARINDEX(',', @RequestDataIDs) - 1, -1),
									LEN(@RequestDataIDs)))
			SET @RequestDataIDs = SUBSTRING(@RequestDataIDs,
										 ISNULL(NULLIF(CHARINDEX(',', @RequestDataIDs), 0),
										 LEN(@RequestDataIDs)) + 1, LEN(@RequestDataIDs))

			INSERT INTO @OutputTable ( [requestDataId] )
			VALUES ( CAST(@String as int ) )
		END

		Declare @oldRequestDataId INT
		Declare @RequestDataId INT
		
		Declare oldRequestDataCursor CURSOR FOR Select [requestDataId] From @OutputTable;
		
		OPEN oldRequestDataCursor;
		
		FETCH NEXT FROM oldRequestDataCursor
		INTO @oldRequestDataId;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @Status_Code = 0
			SET @Status_Text = 'OK'

			-- Store the RequestData metadata.
			Insert Into dbo.RequestData(RequestID,
									PacketNumber,
									ActionType,
									DataSetID,
									CDRID,
									CDRVersion,
									[Status],
									DependencyStatus,
									Location,
									GroupID,
									ReceivedDate,
									isArchived)
			Select @RequestID,
					PacketNumber,
					ActionType,
					DataSetID,
					CDRID,
					CDRVersion,
					[Status],
					DependencyStatus,
					Location,
					GroupID,
					GETDATE(),
					0
			FROM dbo.RequestData
			Where RequestDataId = @oldRequestDataId
			
			SET @RequestDataID = SCOPE_IDENTITY()

			-- Store the document data in it's own table.
			insert into dbo.DocumentData(RequestDataID, Data)
			Select @RequestDataID, Data 
			From DocumentData
			Where RequestDataID = @oldRequestDataId

		FETCH NEXT FROM oldRequestDataCursor
		INTO @oldRequestDataId;
	END
	-- Mark the request as Updated
	update dbo.Request
		set UpdateDate = GETDATE(),
		UpdateUserID = @updateUserID
	where RequestID = @RequestID
	
	CLOSE oldRequestDataCursor;
	DEALLOCATE oldRequestDataCursor;


	RETURN 0  --Succesful return 0

	END TRY
	BEGIN CATCH
	CLOSE oldRequestDataCursor;
	DEALLOCATE oldRequestDataCursor;
	
		SET @Status_Text = ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END

GO
grant execute on dbo.usp_CopyRequestData to gatekeeper_role
