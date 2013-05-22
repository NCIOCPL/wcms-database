--c.	The stored procedure for generating report for content header will include name, updateuserID.
if object_id('usp_SearchInvalidXHTMLView') is not null
	drop procedure dbo.usp_SearchInvalidXHTMLView
GO
Create procedure dbo.usp_SearchInvalidXHTMLView (@DTDLocation nvarchar(300) = N'C:\\Temp\\xhtml1-transitional.dtd')
As
BEGIN

	declare @View table (nciviewid uniqueidentifier )
	declare @docView table (nciviewid uniqueidentifier )
	declare @desView table (nciviewid uniqueidentifier )
	declare @listView table (nciviewid uniqueidentifier )
	declare @externalobjectView table (nciviewid uniqueidentifier )

		insert into @view
		select distinct nciviewid from viewobjects
			where nciviewid not in
					(select nciviewid 
						from nciview v inner join ncitemplate t on t.ncitemplateid = v.ncitemplateid
						where name in ('Benchmark', 'NEWSLETTER', 'summary') 
								or ncisectionid = 'F2901263-4A99-44A8-A1DA-92B16E173E86' --druginfo
					)
					
		  
					
			insert into @DocView
			select v.nciviewid
						from  dbo.viewobjects  vo with (nolock) inner join dbo.document   d with (nolock)
								on d.documentid = vo.objectid
								inner join @view v on v.nciviewid = vo.nciviewid
						where   type not in ('SEARCH','VirSearch')
								and 
									(dbo.udf_IsValidXHTML(data,@DTDLocation) = 0 
									or dbo.udf_IsValidXHTML(description,@DTDLocation) = 0 
									or dbo.udf_IsValidXHTML(toc,@DTDLocation) = 0 
									)	



			delete  from @view 
				where nciviewid in
					(select nciviewid from @DocView)


			insert into @externalobjectView
			select v.nciviewid
					from  dbo.viewobjects vo with (nolock) inner join dbo.externalobject e with (nolock) on e.externalobjectid = vo.objectid
							inner join @view v on v.nciviewid = vo.nciviewid
					where 	
								(dbo.udf_IsValidXHTML(text,@DTDLocation) = 0 
								or dbo.udf_IsValidXHTML(description,@DTDLocation) = 0 
								)
			delete  from @view 
			where nciviewid in 
				(select nciviewid from @externalobjectView )


			insert into @desView
			select v.nciviewid from dbo.nciview v1 with (nolock)
					inner join @view v on v.nciviewid = v1.nciviewid
			where  dbo.udf_IsValidXHTML(description,@DTDLocation) = 0 

			delete from @view
			where nciviewid in 
			(select nciviewid from @desView	)


			insert into @listView
			select v.nciviewid from 
				viewobjects vo with (nolock) inner join list l with (nolock) on l.listid = vo.objectid
					inner join @view v on v.nciviewid = vo.nciviewid
			where  l.listDesc is not null and dbo.udf_IsValidXHTML(listDesc,@DTDLocation) = 0 

			delete from @view
			where nciviewid in
			(select nciviewid from @listView)


		
		select distinct nciviewid from viewobjects
			where nciviewid not in
					(select nciviewid 
						from nciview v inner join ncitemplate t on t.ncitemplateid = v.ncitemplateid
						where name in ('Benchmark', 'NEWSLETTER', 'summary') 
								or ncisectionid = 'F2901263-4A99-44A8-A1DA-92B16E173E86' --druginfo
					)
				and nciviewid not in
				(select nciviewid from @view)
		

END
GO
grant execute on dbo.usp_SearchInvalidXHTMLView to webadminuser_role


	


		
		

		