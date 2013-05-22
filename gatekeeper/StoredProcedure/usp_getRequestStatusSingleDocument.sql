IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_getRequestStatusSingleDocument]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_getRequestStatusSingleDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

create procedure dbo.usp_getRequestStatusSingleDocument
	@CDRID varchar(40) -- CDRID
as
begin
set nocount on
	Declare @nullValue varchar(20)
	select @nullValue= 'Not Present'

	select
	(
			SELECT t.cdrid, ( select case t.actiontype when 'Remove' then @nullValue else  externalRequestId end from dbo.request where requestid= t.reqid ) AS gatekeeper, 
			t.ReceivedDate AS gatekeeperDateTime,
			ISNULL(convert(varchar(20), (select externalRequestID from request r inner join requestData rd on r.requestID = rd.requestID where rd.requestDataID = l.previewrequestDataID), 126), @nullValue)  AS preview,
			ISNULL(convert(varchar(26), l.previewUpdateTime, 126), @nullValue)  AS previewDateTime,
			ISNULL(convert(varchar(20), (select externalRequestID from request r inner join requestData rd on r.requestID = rd.requestID where rd.requestDataID = l.liveRequestDataID), 126), @nullValue)  AS live,
			ISNULL(convert(varchar(26), l.liveUpdateTime, 126), @nullValue)  AS liveDateTime
		FROM (SELECT t1.CDRID, t1.ReqID, rd.ReceivedDate, rd.DataSetID, rd.actiontype
				FROM (SELECT CDRID, MAX(RequestID) AS ReqID FROM dbo.RequestData
						GROUP BY CDRID) t1 
				INNER JOIN dbo.RequestData rd 
				ON rd.CDRID = t1.CDRID and rd.RequestID = t1.ReqID
				) t
		LEFT JOIN dbo.CDRDocumentLocation l
		ON t.CDRID = l.CDRID
		where t.cdrid = @CDRID
		ORDER BY t.CDRID
		FOR XML RAW('document'),  
		TYPE, ROOT('documentList')
	) as detailedMessage
	FOR XML RAW(''), ELEMENTS , TYPE, 
	ROOT('Response')

end

GO
GRANT EXECUTE ON [dbo].[usp_getRequestStatusSingleDocument] TO [gatekeeper_role]
GO
