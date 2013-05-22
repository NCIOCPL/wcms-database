--c.	The stored procedure for generating report for content header will include name, updateuserID.
if object_id('usp_invalidXHTMLView_update') is not null
	drop procedure dbo.usp_invalidXHTMLView_update
GO
Create procedure dbo.usp_invalidXHTMLView_update (@DTDLocation nvarchar(300) = N'C:\\Temp\\xhtml1-transitional.dtd')
As
BEGIN
	create table #invalidView (nciviewid uniqueidentifier primary key)
	insert into #invalidView exec dbo.usp_SearchInvalidXHTMLView @DTDLocation
	
	delete from dbo.invalidXHTMLView 
		where nciviewid not in (select nciviewid from dbo.#invalidView)

	insert into dbo.invalidXHTMLView 
		select nciviewid from #invalidView where nciviewid not in (select nciviewid from dbo.invalidXHTMLView)

END
GO
grant execute on dbo.usp_invalidXHTMLView_update to webadminuser_role
