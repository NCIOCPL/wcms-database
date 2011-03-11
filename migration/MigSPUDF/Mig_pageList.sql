drop procedure dbo.Mig_pagelist
go
create procedure dbo.Mig_pagelist
as

select distinct m.nciviewid as viewid, [page content type],
		m.objectid, slot, [Snippet Content Type],  
		case [Snippet Template] 
		when 'cgvSnListWithDescription' 
		then 'cgvSnCancerTypeHPList'
			when 'cgvSnCancerTypeHomeList' then 'cgvSnCancerTypeHPList'
		else [Snippet Template] END as [Snippet Template]

		, l.listname as list_title, l.listdesc as list_description, 
		isnull(vo.priority,1) as priority
	, (select top 1 currenturl from prettyurl p where p.nciviewid = l.nciviewid order by isprimary desc, isroot desc) as url
		, (select case when propertyvalue = 'true' then 0 else NULL END from dbo.viewobjectproperty vop 
			where vop.nciviewobjectid = vo.nciviewobjectid and propertyname = 'suppresspagetitle')
			as showpagetitle

	from migmap m inner join list l on m.objectid = l.listid 
	left join dbo.viewobjects vo on vo.nciviewid = m.nciviewid and m.objectid = vo.objectid
		where [snippet content type] = 'ncilist'
		and [cancergov template] <> 'Digestpage'
	
--		
--union 
----DigestPage list
--	select distinct m.nciviewid,  [page content type], l.listid, slot, 
--	[Snippet Content Type], 
--	case [Snippet Template] when 'cgvSnListWithDescription' then 'cgvSnCancerTypeHPList'
--			when 'cgvSnCancerTypeHomeList' then 'cgvSnCancerTypeHPList'
--		else [Snippet Template] END as [Snippet Template]
--
--			, l.listname,  l.listdesc ,vo.priority
--		, (select top 1 currenturl from prettyurl p where p.nciviewid = l.nciviewid order by isprimary desc, isroot desc) as url
--		, (select case when propertyvalue = 'true' then 0 else NULL END from dbo.viewobjectproperty vop 
--			where vop.nciviewobjectid = vo.nciviewobjectid and propertyname = 'suppresspagetitle')
--			as showpagetitle
--
--		from  viewobjects vo inner join viewobjectproperty vop on vop.nciviewobjectid = vo.nciviewobjectid
--		inner join list l on l.parentlistid = vop.propertyvalue
--		inner join migmap m on m.objectid = l.listid
--		where [cancergov template] = 'digestpage' and propertyname = 'DigestRelatedListID'
--	
order by m.nciviewid, priority
GO


