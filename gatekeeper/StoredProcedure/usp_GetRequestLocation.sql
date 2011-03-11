IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetRequestLocation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GetRequestLocation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- =============================================
-- Author:		Vadim
-- Create date: 05/02/2007
-- Description:	Get location for different RequestIDs
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetRequestLocation]
	@DataSetID int, 
	@CdrID int,
	@Status_Code int OUTPUT,
	@Status_Text	varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY

		SET NOCOUNT ON;
		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		DECLARE @nullValue int
		SELECT @nullValue = 0

		if @cdrid = 0 and @datasetid = 0
				SELECT t.cdrid, ( select case t.actiontype when 'Remove' then null else  requestid end from dbo.request where requestid= t.reqid ) AS gatekeeper, 
					t.ReceivedDate AS gatekeeperDateTime, t.DataSetID AS DocType,
					(select requestID from dbo.RequestData where RequestDataID = l.stagingrequestDataID) AS staging,
					l.stagingUpdateTime AS stagingDateTime,
					(select requestID from dbo.RequestData where RequestDataID = l.previewrequestDataID) AS preview,
					l.previewUpdateTime AS previewDateTime,
					(select requestID from dbo.RequestData where RequestDataID = l.liveRequestDataID) AS live,
					l.liveUpdateTime AS liveDateTime
				FROM (SELECT t1.CDRID, t1.ReqID, rd.ReceivedDate, rd.DataSetID, rd.actiontype
						FROM (SELECT CDRID, MAX(RequestID) AS ReqID FROM dbo.RequestData
								GROUP BY CDRID) t1 
						INNER JOIN dbo.RequestData rd 
						ON rd.CDRID = t1.CDRID and rd.RequestID = t1.ReqID
						) t
				LEFT JOIN dbo.CDRDocumentLocation l
				ON t.CDRID = l.CDRID
				ORDER BY t.CDRID
	else
	
		if @cdrid = 0 and @datasetid <> 0
					SELECT t.cdrid, ( select case t.actiontype when 'Remove' then null else  requestid end from dbo.request where requestid= t.reqid ) AS gatekeeper, 
					t.ReceivedDate AS gatekeeperDateTime, t.DataSetID AS DocType,
					(select requestID from dbo.RequestData where RequestDataID = l.stagingrequestDataID) AS staging,
					l.stagingUpdateTime AS stagingDateTime,
					(select requestID from dbo.RequestData where RequestDataID = l.previewrequestDataID) AS preview,
					l.previewUpdateTime AS previewDateTime,
					(select requestID from dbo.RequestData where RequestDataID = l.liveRequestDataID) AS live,
					l.liveUpdateTime AS liveDateTime
				FROM (SELECT t1.CDRID, t1.ReqID, rd.ReceivedDate, rd.DataSetID, rd.actiontype
						FROM (SELECT CDRID, MAX(RequestID) AS ReqID FROM dbo.RequestData
								GROUP BY CDRID) t1 
						INNER JOIN dbo.RequestData rd 
						ON rd.CDRID = t1.CDRID and rd.RequestID = t1.ReqID
						) t
				LEFT JOIN dbo.CDRDocumentLocation l
				ON t.CDRID = l.CDRID
				where datasetid = @datasetid
				ORDER BY t.CDRID

		else
					SELECT t.cdrid, ( select case t.actiontype when 'Remove' then null else  requestid end from dbo.request where requestid= t.reqid ) AS gatekeeper, 
					t.ReceivedDate AS gatekeeperDateTime, t.DataSetID AS DocType,
					(select requestID from dbo.RequestData where RequestDataID = l.stagingrequestDataID) AS staging,
					l.stagingUpdateTime AS stagingDateTime,
					(select requestID from dbo.RequestData where RequestDataID = l.previewrequestDataID) AS preview,
					l.previewUpdateTime AS previewDateTime,
					(select requestID from dbo.RequestData where RequestDataID = l.liveRequestDataID) AS live,
					l.liveUpdateTime AS liveDateTime
				FROM (SELECT t1.CDRID, t1.ReqID, rd.ReceivedDate, rd.DataSetID, rd.actiontype
						FROM (SELECT CDRID, MAX(RequestID) AS ReqID FROM dbo.RequestData
								GROUP BY CDRID) t1 
						INNER JOIN dbo.RequestData rd 
						ON rd.CDRID = t1.CDRID and rd.RequestID = t1.ReqID
						) t
				LEFT JOIN dbo.CDRDocumentLocation l
				ON t.CDRID = l.CDRID
				where t.cdrid = @cdrid
				ORDER BY t.CDRID

	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Exception thrown in usp_GetRequestLocation ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[usp_GetRequestLocation] TO [gatekeeper_role]
GO
