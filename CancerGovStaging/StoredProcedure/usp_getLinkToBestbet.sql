if object_id('usp_getLinkToBestbet') is not NULL
drop procedure dbo.usp_getLinkToBestbet
GO
Create procedure dbo.usp_getLinkToBestbet (@nciviewid uniqueidentifier)
as
BEGIN
	set nocount on

	select categoryid, catname as [Category Name]
	from dbo.listitem li inner join dbo.bestbetcategories b on li.listid = b.listid
	where li.nciviewid = @nciviewid
	order by 1

END 
GO

Grant execute on dbo.usp_getLinkToBestbet to webadminUser_role
