IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SearchRequestData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_SearchRequestData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
create procedure dbo.usp_SearchRequestData
	@requestID int = NULL,
	@actionType varchar(50) = NULL,
	@datasetID varchar(50)= NULL,
	@documentStatus varchar(50)= NULL,
	@dependencyStatus varchar(50)= NULL,
	@location varchar(50) = NULL,
	@sortOrder smallint = 0,
	@pageNumber int = 1,
	@ResultsPerPage int = 0,
	@TotalRequestDataCount int output,
	@BatchID int = NULL
	as
	begin
	set nocount on
		create table #result (rownumber int primary key, requestdataID int)
		insert into #result(rownumber, requestDataID)
		select 
		row_number() over (order by 
							case @sortorder when 111 then packetnumber end,
							case @sortorder when 112 then packetnumber end desc,
							case @sortorder when 121 then GroupID end,
							case @sortorder when 122 then GroupID end desc,
							case @sortorder when 131 then CDRID end,
							case @sortorder when 132 then CDRID end desc,
							case @sortorder when 141 then actionType end,
							case @sortorder when 142 then actionType end desc,
							case @sortorder when 151 then t.name end,
							case @sortorder when 152 then t.name end desc,
							case @sortorder when 161 then d.Status end,
							case @sortorder when 162 then d.Status end desc,
							case @sortorder when 171 then dependencystatus end,
							case @sortorder when 172 then dependencystatus end desc,
							case @sortorder when 181 then location end,
							case @sortorder when 182 then location end desc)
		as rownumber ,
		requestDataID
		from 
		dbo.requestData d with (nolock) 
		inner join dbo.documenttypemap m on m.datasetid = d.datasetid
		inner join dbo.documenttype t on t.documenttypeid = m.documenttypeid
		where 
			(@requestID is  NULL or	requestID =  @requestID )
			and 
			(@batchID is  NULL or requestDataID in (select requestDataID from dbo.batchRequestData where batchID = @batchID))
			and
			( @actionType is Null or actiontype = @actionType)
			and
			(@datasetID is null or 
				d.datasetID  = @datasetID
			)
			and 
			( @documentstatus is null or d.status = @documentStatus )
			and
			(@dependencyStatus is null or dependencystatus = @dependencystatus)
			and 
			(@location is null or location = @location )
			order by 
					case @sortorder when 111 then packetnumber end,
					case @sortorder when 112 then packetnumber end desc,
					case @sortorder when 121 then GroupID end,
					case @sortorder when 122 then GroupID end desc,
					case @sortorder when 131 then CDRID end,
					case @sortorder when 132 then CDRID end desc,
					case @sortorder when 141 then actionType end,
					case @sortorder when 142 then actionType end desc,
					case @sortorder when 151 then t.name end,
					case @sortorder when 152 then t.name end desc,
					case @sortorder when 161 then d.Status end,
					case @sortorder when 162 then d.Status end desc,
					case @sortorder when 171 then dependencystatus end,
					case @sortorder when 172 then dependencystatus end desc,
					case @sortorder when 181 then location end,
					case @sortorder when 182 then location end desc


		--select * from #result
		
		select 
				req.RequestDataID, 
				req.RequestID, 
				req.PacketNumber, 
				req.ActionType, 
				req.DataSetID,
				req.CDRID, 
				req.CDRVersion, 
				req.ReceivedDate, 
				req.Status, 
				req.DependencyStatus,
				req.Location, 
				req.groupID,
				NULL as Data
		from #result s inner join
				dbo.requestData req with (nolock) on s.requestDataid = req.requestDataID
		where
				( @ResultsPerPage = 0 or 
					(rowNumber > = (@pageNumber -1) * @ResultsPerPage 
					and rowNumber < = @pageNumber  * @ResultsPerPage
					)
				)
		order by rownumber

	set @TotalRequestDataCount = (select count(*) from dbo.requestData where requestID = @requestID)

end

GO
GRANT EXECUTE ON [dbo].[usp_SearchRequestData] TO [gatekeeper_role]
GO
