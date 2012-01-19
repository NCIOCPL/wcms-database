IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetRequestLocation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GetRequestLocation]
GO
CREATE PROCEDURE [dbo].[usp_GetRequestLocation]  
 @DataSetID int,   
 @CdrID int,  
 @Status_Code int OUTPUT,  
 @Status_Text varchar(255) OUTPUT  
AS  
BEGIN  
 BEGIN TRY  
  
  SET NOCOUNT ON;  
  SET @Status_Code = 0  
  SET @Status_Text = 'OK'  
  
  DECLARE @nullValue int  
  SELECT @nullValue = 0  
  
  if @cdrid = 0 and @datasetid = 0  
    SELECT t.cdrid,   
	dbo.udf_getdocumenttitle(MaxRequestDataID, datasetid) as Title,
    ( select case t.actiontype when 'Remove' then null else  requestid end   
     from dbo.request   
     where requestid= t.Maxreqid ) AS gatekeeper,   
     (select DTDVersion  
     from dbo.request   
     where requestid= t.Maxreqid ) AS gateKeeperDTDVersion, 
     MaxRequestDataID as gateKeeperRequestDataID,  
     t.ReceivedDate AS gatekeeperDateTime, t.DataSetID AS DocType,  
	(select requestID from dbo.RequestData   
     where RequestDataID = l.stagingrequestDataID) AS staging,  
     (select DTDVersion   
      from Dbo.request r inner join dbo.RequestData rd on r.requestid = rd.requestid  
      where RequestDataID = l.stagingrequestDataID) AS stagingDTDVersion,  
     l.stagingUpdateTime AS stagingDateTime,  
      l.stagingRequestDataID,  
     (select requestID from dbo.RequestData where RequestDataID = l.previewrequestDataID) AS preview,  
     (select DTDVersion   
      from Dbo.request r inner join dbo.RequestData rd on r.requestid = rd.requestid  
      where RequestDataID = l.previewrequestDataID) AS previewDTDVersion,  
     l.previewUpdateTime AS previewDateTime,  
     l.previewRequestDataID,  
     (select requestID from dbo.RequestData where RequestDataID = l.liveRequestDataID) AS live,  
     (select DTDVersion   
      from Dbo.request r inner join dbo.RequestData rd on r.requestid = rd.requestid  
      where RequestDataID = l.liverequestDataID) AS liveDTDVersion,  
     l.liveUpdateTime AS liveDateTime,  
     l.liveRequestDataID  ,
     (select CompleteReceivedTime
     from dbo.request  r inner join dbo.requestdata rd on r.requestid = rd.requestid  
      where RequestDataID = l.liverequestDataID) AS CompleteReceivedTime, 
	 (select externalrequestID
     from dbo.request  r inner join dbo.requestdata rd on r.requestid = rd.requestid  
      where RequestDataID = l.liverequestDataID) AS externalrequestID,
	(select groupid from requestdata where requestdataid = l.liverequestDataID) as GroupID,
	(select actiontype from requestdata where requestdataid = l.liverequestDataID ) as actiontype,
	(select r.status from dbo.request r inner join dbo.requestdata rd on r.requestid = rd.requestid  
      where RequestDataID = l.liverequestDataID ) AS Status
    FROM   
     (SELECT t1.CDRID, t1.MaxReqID, rd.ReceivedDate, rd.DataSetID, rd.actiontype,  rd.requestDataID as MaxRequestDataID  
      FROM   
       (SELECT CDRID, MAX(RequestID) AS MaxReqID   
        FROM dbo.RequestData  
        GROUP BY CDRID) t1   
        INNER JOIN dbo.RequestData rd   
         ON rd.CDRID = t1.CDRID and rd.RequestID = t1.MaxReqID  
     ) t  
    LEFT JOIN dbo.CDRDocumentLocation l ON t.CDRID = l.CDRID  
    ORDER BY t.CDRID  
 else  
   
  if @cdrid = 0 and @datasetid <> 0  
    SELECT t.cdrid,   
	dbo.udf_getdocumenttitle(MaxRequestDataID, datasetid) as Title,
    ( select case t.actiontype when 'Remove' then null else  requestid end   
     from dbo.request   
     where requestid= t.Maxreqid ) AS gatekeeper,   
     (select DTDVersion  
     from dbo.request   
     where requestid= t.Maxreqid ) AS gateKeeperDTDVersion,   
     MaxRequestDataID as gateKeeperRequestDataID,  
     t.ReceivedDate AS gatekeeperDateTime, t.DataSetID AS DocType,  
	(select requestID from dbo.RequestData   
     where RequestDataID = l.stagingrequestDataID) AS staging,  
     (select DTDVersion   
      from Dbo.request r inner join dbo.RequestData rd on r.requestid = rd.requestid  
      where RequestDataID = l.stagingrequestDataID) AS stagingDTDVersion,  
     l.stagingUpdateTime AS stagingDateTime,  
      l.stagingRequestDataID,  
     (select requestID from dbo.RequestData where RequestDataID = l.previewrequestDataID) AS preview,  
     (select DTDVersion   
      from Dbo.request r inner join dbo.RequestData rd on r.requestid = rd.requestid  
      where RequestDataID = l.previewrequestDataID) AS previewDTDVersion,  
     l.previewUpdateTime AS previewDateTime,  
     l.previewRequestDataID,  
     (select requestID from dbo.RequestData where RequestDataID = l.liveRequestDataID) AS live,  
     (select DTDVersion   
      from Dbo.request r inner join dbo.RequestData rd on r.requestid = rd.requestid  
      where RequestDataID = l.liverequestDataID) AS liveDTDVersion,  
     l.liveUpdateTime AS liveDateTime,  
     l.liveRequestDataID    ,
     (select CompleteReceivedTime
     from dbo.request  r inner join dbo.requestdata rd on r.requestid = rd.requestid  
      where RequestDataID = l.liverequestDataID) AS CompleteReceivedTime, 
	 (select externalrequestID
	  from dbo.request  r inner join dbo.requestdata rd on r.requestid = rd.requestid  
      where RequestDataID = l.liverequestDataID) AS externalrequestID,
    (select groupid from requestdata where requestdataid = l.liverequestDataID) as GroupID,
	(select actiontype from requestdata where requestdataid = l.liverequestDataID ) as actiontype,
	(select r.status from dbo.request r inner join dbo.requestdata rd on r.requestid = rd.requestid  
      where RequestDataID = l.liverequestDataID ) AS Status   
    FROM   
     (SELECT t1.CDRID, t1.MaxReqID, rd.ReceivedDate, rd.DataSetID, rd.actiontype,  rd.requestDataID as MaxRequestDataID  
      FROM   
       (SELECT CDRID, MAX(RequestID) AS MaxReqID   
        FROM dbo.RequestData  
        GROUP BY CDRID) t1   
        INNER JOIN dbo.RequestData rd   
         ON rd.CDRID = t1.CDRID and rd.RequestID = t1.MaxReqID  
     ) t  
    LEFT JOIN dbo.CDRDocumentLocation l ON t.CDRID = l.CDRID  
    where datasetid = @datasetid    
    ORDER BY t.CDRID  
  
  else  
     SELECT t.cdrid,   
	dbo.udf_getdocumenttitle(MaxRequestDataID, datasetid) as Title,
    ( select case t.actiontype when 'Remove' then null else  requestid end   
     from dbo.request   
     where requestid= t.Maxreqid ) AS gatekeeper,   
     (select DTDVersion  
     from dbo.request   
     where requestid= t.Maxreqid ) AS gateKeeperDTDVersion,   
	  MaxRequestDataID as gateKeeperRequestDataID,  
     t.ReceivedDate AS gatekeeperDateTime, t.DataSetID AS DocType,  
	 (select requestID from dbo.RequestData   
     where RequestDataID = l.stagingrequestDataID) AS staging,  
     (select DTDVersion   
      from Dbo.request r inner join dbo.RequestData rd on r.requestid = rd.requestid  
      where RequestDataID = l.stagingrequestDataID) AS stagingDTDVersion,  
     l.stagingUpdateTime AS stagingDateTime,  
      l.stagingRequestDataID,  
     (select requestID from dbo.RequestData where RequestDataID = l.previewrequestDataID) AS preview,  
     (select DTDVersion   
      from Dbo.request r inner join dbo.RequestData rd on r.requestid = rd.requestid  
      where RequestDataID = l.previewrequestDataID) AS previewDTDVersion,  
     l.previewUpdateTime AS previewDateTime,  
     l.previewRequestDataID,  
     (select requestID from dbo.RequestData where RequestDataID = l.liveRequestDataID) AS live,  
     (select DTDVersion   
      from Dbo.request r inner join dbo.RequestData rd on r.requestid = rd.requestid  
      where RequestDataID = l.liverequestDataID) AS liveDTDVersion,  
     l.liveUpdateTime AS liveDateTime,  
     l.liveRequestDataID    ,
     (select CompleteReceivedTime
     from dbo.request  r inner join dbo.requestdata rd on r.requestid = rd.requestid  
      where RequestDataID = l.liverequestDataID) AS CompleteReceivedTime, 
	 (select externalrequestID
     from dbo.request  r inner join dbo.requestdata rd on r.requestid = rd.requestid  
      where RequestDataID = l.liverequestDataID) AS externalrequestID,
    (select groupid from requestdata where requestdataid = l.liverequestDataID) as GroupID,
	(select actiontype from requestdata where requestdataid = l.liverequestDataID ) as actiontype,
	(select r.status from dbo.request r inner join dbo.requestdata rd on r.requestid = rd.requestid  
      where RequestDataID = l.liverequestDataID ) AS Status   
    FROM   
     (SELECT t1.CDRID, t1.MaxReqID, rd.ReceivedDate, rd.DataSetID, rd.actiontype,  rd.requestDataID as MaxRequestDataID  
      FROM   
       (SELECT CDRID, MAX(RequestID) AS MaxReqID   
        FROM dbo.RequestData  
        GROUP BY CDRID) t1   
        INNER JOIN dbo.RequestData rd   
         ON rd.CDRID = t1.CDRID and rd.RequestID = t1.MaxReqID  
     ) t  
    LEFT JOIN dbo.CDRDocumentLocation l ON t.CDRID = l.CDRID  
    where t.cdrid = @cdrid    
    ORDER BY t.CDRID  
  
 END TRY  
  
 BEGIN CATCH  
  SET @Status_Code = -1000 -- Very big error  
  SET @Status_Text = 'Exception thrown in usp_GetRequestLocation ' + ERROR_MESSAGE()  
  RETURN 100101  --Error code  
 END CATCH   
END  
  GO
GRANT EXECUTE ON [dbo].[usp_GetRequestLocation] TO [gatekeeper_role]
GO
