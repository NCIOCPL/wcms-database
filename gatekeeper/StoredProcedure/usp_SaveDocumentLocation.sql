IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SaveDocumentLocation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_SaveDocumentLocation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_SaveDocumentLocation
	@RequestDataID	int,
	@ActionType varchar(50),
	@Location	varchar(50),
	@Status_Code int OUTPUT,
	@Status_Text	varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		-- Update the document location in the master copy.
		update dbo.RequestData
			Set Location = @Location
		where RequestDataID = @RequestDataID

		-- Update the document location roll-up table.
		DECLARE @Cdrid int
		Set @Cdrid = (select CDRID from dbo.RequestData where RequestDataID = @RequestDataID)

		DECLARE @Record_count int
		Set @Record_count = (select count(*) from dbo.CDRDocumentLocation where cdrid = @Cdrid)

		IF( @Record_count = 0)
		BEGIN
			-- New records are only created when a document is promoted to staging,
			-- so there's no need to check the location.
			insert into dbo.CDRDocumentLocation(CDRID,
											stagingrequestDataID,
											stagingUpdateTime,
											previewrequestDataID,
											previewUpdateTime,
											liveRequestDataID,
											liveUpdateTime)
			values(@cdrid, @RequestDataID, GETDATE(), null, null, null, null)
		END
		ELSE
		BEGIN
			-- For remove actions, the location ID column is set to null
			IF(@ActionType = 'Remove')
				Set @RequestDataID = NULL

			IF(@Location = 'Staging')
				update dbo.CDRDocumentLocation
					set stagingrequestDataID = @RequestDataID,
						stagingUpdateTime = GETDATE()
				where cdrid = @Cdrid
			ELSE IF(@Location = 'Preview')
				update dbo.CDRDocumentLocation
					set previewrequestDataID = @RequestDataID,
						previewUpdateTime = GETDATE()
				where cdrid = @Cdrid
			ELSE IF(@Location = 'Live')
				update dbo.CDRDocumentLocation
					set liveRequestDataID = @RequestDataID,
						liveUpdateTime = GETDATE()
				where cdrid = @Cdrid
			ELSE
			BEGIN
				SET @Status_Code = -1
				SET @Status_Text = 'usp_SaveDocumentLocation -- Unknown location: ' + @Location
			END

		END

		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Exception thrown in usp_SaveDocumentLocation ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_SaveDocumentLocation] TO [gatekeeper_role]
GO
