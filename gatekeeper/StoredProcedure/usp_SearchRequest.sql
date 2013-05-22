IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SearchRequest]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_SearchRequest]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].usp_SearchRequest
	@month int = NULL,
	@CDRID varchar(200) = NULL,
	@status varchar(50) = null,
	@publicationtarget varchar(20) = null,
	@sortOrder smallint = 122,
	@pageNumber int = 1,
	@ResultsPerPage int = 0
AS
BEGIN
	
	set nocount ON
		
		create table #result (rownumber int primary key, requestID int)
		create unique index NC_Result on #result (requestid) 

		insert into #result(rownumber, requestID)
		select 
		row_number() over (order by 
							case @sortorder when 111 then initiateDate end,
							case @sortorder when 112 then initiateDate end desc,
							case @sortorder when 121 then RequestID end,
							case @sortorder when 122 then RequestID end desc,
							case @sortorder when 131 then ExternalRequestId end,
							case @sortorder when 132 then ExternalRequestId end desc,
							case @sortorder when 141 then status end,
							case @sortorder when 142 then status end desc,
							case @sortorder when 151 then publicationTarget end,
							case @sortorder when 152 then publicationTarget end desc,
							case @sortorder when 161 then Source end,
							case @sortorder when 162 then Source end desc
							)
		as rownumber ,
		requestID
		from dbo.request r with (nolock)
			where ( @month is null or 
					(initiatedate > = dateAdd(month,0-@month,getdate()) ))
					and (@CDRID is null or 
							exists (select * from dbo.requestData RD inner join dbo.udf_listToBigInt( @CDRID, ',') l
								on l.item = RD.CDRID
								where RD.requestID = r.requestID 
								)
						)
					and (@status is null or status = @status)
					and (@publicationTarget is null or publicationTarget = @publicationTarget)
			order by 
							case @sortorder when 111 then initiateDate end,
							case @sortorder when 112 then initiateDate end desc,
							case @sortorder when 121 then RequestID end,
							case @sortorder when 122 then RequestID end desc,
							case @sortorder when 131 then ExternalRequestId end,
							case @sortorder when 132 then ExternalRequestId end desc,
							case @sortorder when 141 then status end,
							case @sortorder when 142 then status end desc,
							case @sortorder when 151 then publicationTarget end,
							case @sortorder when 152 then publicationTarget end desc,
							case @sortorder when 161 then Source end,
							case @sortorder when 162 then Source end desc




	
		select initiateDate, r.requestID, ExternalRequestID, description, status,publicationTarget, source, requestType,
			(select count(*) from dbo.requestData where requestID = r.requestID) as TotalDoc,
			(select count(*) from dbo.requestData where requestID = r.requestID and actionType = 'Export') as TotalExport,
			(select count(*) from dbo.requestData where requestID = r.requestID and actionType = 'remove') as TotalRemove,
			(select count(*) from dbo.requestData where requestID = r.requestID and Location in ('Preview','Live' )) as TotalPreview,
			(select count(*) from dbo.requestData where requestID = r.requestID and Location = 'Live') as TotalLive,
			(select count(*) from dbo.requestData where requestID = r.requestID and status = 'Error') as TotalError,
			(select count(*) from dbo.requestData where requestID = r.requestID and Status = 'warning') as TotalWarning,
			(select count(*) from dbo.requestData where requestID = r.requestID and Location in ('Staging','Preview','Live')) as TotalStaging
		from  #result s inner join dbo.request r with (nolock)  on s.requestid = r.requestID
		where
				( @ResultsPerPage = 0 or 
					(rowNumber > = (@pageNumber -1) * @ResultsPerPage 
					and rowNumber < = @pageNumber  * @ResultsPerPage
					)
				)
		order by rownumber

	

END


GO
GRANT EXECUTE ON [dbo].[usp_SearchRequest] TO [gatekeeper_role]
GO
