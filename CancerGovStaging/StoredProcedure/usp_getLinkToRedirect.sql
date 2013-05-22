if object_id('usp_getLinkToRedirect') is not NULL
drop procedure dbo.usp_getLinkToRedirect
GO
Create procedure dbo.usp_getLinkToRedirect (@nciviewid uniqueidentifier)
as
BEGIN
	set nocount on

	select v.nciviewid, v.shorttitle as [Short Title], 
	(select top 1 currenturl from dbo.prettyurl p where p.nciviewid = v.nciviewid order by isprimary desc, isroot desc) as [Pretty URL]
	, previewlive
	from
		(
		select nciviewid, sum(previewLive) as previewLive
		from
			(	
			select nciviewid ,1 as previewLive
			from dbo.viewproperty vp 
			where vp.propertyname = 'redirecturl' 
				and propertyvalue in (select currenturl from dbo.prettyurl p where p.nciviewid = @nciviewid)
			union all
			select nciviewid, 2 as previewLive
			from cancergov.dbo.viewproperty vp 
			where vp.propertyname = 'redirecturl' 
				and propertyvalue in (select currenturl from cancergov.dbo.prettyurl p where p.nciviewid = @nciviewid)
			) a 
			group by nciviewid
		) b 
		inner join dbo.nciview v on v.nciviewid = b.nciviewid
 	order by 1

	

END 
GO

Grant execute on dbo.usp_getLinkToRedirect to webadminUser_role
