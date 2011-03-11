IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetRequestDataForCDRLocations]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GetRequestDataForCDRLocations]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_GetRequestDataForCDRLocations
	@CDRID varchar(200) = NULL
AS
BEGIN

	set nocount ON

-- Most recent GateKeeper version
select top 1 R.*, NULL as Data
from RequestData R
where  cdrid=@CDRID
order by requestID desc

-- Staging version
select R.*, NULL as Data
from RequestData R
left join CDRDocumentLocation L 
on stagingRequestDataId = requestDataId
where  L.cdrid=@CDRID

-- Preview version
select R.*, NULL as Data
from RequestData R
left join CDRDocumentLocation L 
on previewRequestDataId = requestDataId
where  L.cdrid=@CDRID

-- Live version
select R.*, NULL as Data
from RequestData R
left join CDRDocumentLocation L 
on liveRequestDataId = requestDataId
where  L.cdrid=@CDRID
END


GO
GRANT EXECUTE ON [dbo].[usp_GetRequestDataForCDRLocations] TO [gatekeeper_role]
GO
