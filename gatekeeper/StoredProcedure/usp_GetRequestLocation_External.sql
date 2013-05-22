IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetRequestLocation_External]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GetRequestLocation_External]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

-- =============================================
-- Description:	Report a history of which document versions
--				are present on Gatekeeper, preview and staging.
--				Reports ExternalIDs
--
--		If @Cdrid is non-zero, report for that cdrid only.
--		If @Cdrid is zero, report versions for the universe of Cdrids.
-- =============================================
create procedure dbo.usp_GetRequestLocation_External
	@Cdrid int,
	@Status_Code int OUTPUT,
	@Status_Text	varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
		set nocount on
		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		SELECT t.cdrid, ( select case t.actiontype when 'Remove' then NULL else  externalRequestId end from dbo.request where requestid= t.reqid ) AS gatekeeper, 
			t.ReceivedDate AS gatekeeperDateTime,
			(select externalRequestID from request r inner join requestData rd on r.requestID = rd.requestID where rd.requestDataID = l.stagingrequestDataID) AS staging,
			l.stagingUpdateTime AS stagingDateTime,
			(select externalRequestID from request r inner join requestData rd on r.requestID = rd.requestID where rd.requestDataID = l.previewrequestDataID) AS preview,
			l.previewUpdateTime AS previewDateTime,
			(select externalRequestID from request r inner join requestData rd on r.requestID = rd.requestID where rd.requestDataID = l.liveRequestDataID) AS live,
			l.liveUpdateTime AS liveDateTime
		FROM (SELECT t1.CDRID, t1.ReqID, rd.ReceivedDate, rd.DataSetID, rd.actiontype
				FROM (SELECT CDRID, MAX(RequestID) AS ReqID FROM dbo.RequestData
						GROUP BY CDRID) t1 
				INNER JOIN dbo.RequestData rd 
				ON rd.CDRID = t1.CDRID and rd.RequestID = t1.ReqID
				) t
		LEFT JOIN dbo.CDRDocumentLocation l
		ON t.CDRID = l.CDRID
		where t.cdrid = @cdrid OR @cdrid = 0	-- Chooses between Single CdrId or Universe.
		ORDER BY t.CDRID

	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Error in usp_GetRequestLocation_External: ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 

END

GO
GRANT EXECUTE ON [dbo].[usp_GetRequestLocation_External] TO [gatekeeper_role]
GO
