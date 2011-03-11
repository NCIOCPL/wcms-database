IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetCDRIDByRequestID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GetCDRIDByRequestID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_GetCDRIDByRequestID
	@RequestID	int ,
	@documentTypeID int = NULL,
	@pageNumber int = 1,
	@resultsPerPage int = 0
	
AS
BEGIN
set nocount on

create table #result (rownumber int primary key, CDRID int, documentTYpeid int)
insert into #result(rownumber, CDRID, documentTypeid)
	select  row_number() over (order by documenttypeid, CDRID),	 cdrid, documenttypeid
	from dbo.requestData rd  with (nolock) 
		inner join dbo.documenttypeMap m  with (nolock) on m.datasetID = rd.datasetid
	where rd.requestID = @requestID
	 and (@documenttypeid is NULL or 
				@documenttypeid = documenttypeid
			)
	 order by documenttypeid, CDRID

select CDRID, documenttypeid from #result 
where @resultsperpage = 0
	or (rowNumber > = (@pageNumber -1) * @ResultsPerPage 
					and rowNumber <  @pageNumber  * @ResultsPerPage
					)
order by rownumber
	

END


GO
GRANT EXECUTE ON [dbo].[usp_GetCDRIDByRequestID] TO [gatekeeper_role]
GO
