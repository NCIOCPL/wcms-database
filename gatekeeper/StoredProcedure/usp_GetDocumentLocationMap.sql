IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetDocumentLocationMap]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GetDocumentLocationMap]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_GetDocumentLocationMap
	@RequestID int,
	@Status_Code int OUTPUT,
	@Status_Text varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		-- A document which has never been promoted has no rows in CDRDocumentLocation.
		-- Therefore an outer join is needed in order to return rows for those items.
		select rd.cdrid, rd.groupid,
			(select requestID from requestData where requestDataID = stagingrequestDataID) stagingID,
			(select requestID from requestData where requestDataID = previewrequestDataID) previewID,
			(select requestID from requestData where requestDataID = liveRequestDataID) liveID
		from RequestData rd left join CDRDocumentLocation loc on rd.cdrid = loc.cdrid
		where 
			rd.requestID = @RequestID

		IF( @@ROWCOUNT < 1 )
		BEGIN
			Set @Status_Code = 1
			Set @Status_Text = 'No match found for RequestID = ' + CAST(@RequestID AS varchar)
		END

		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Error in usp_GetDocumentLocationMap: ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_GetDocumentLocationMap] TO [gatekeeper_role]
GO
