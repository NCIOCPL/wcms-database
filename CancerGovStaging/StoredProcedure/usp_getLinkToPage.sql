if object_id('usp_getLinkToPage') is not NULL
drop procedure dbo.usp_getLinkToPage
GO
Create procedure dbo.usp_getLinkToPage (@nciviewid uniqueidentifier)
as
BEGIN
	set nocount on
	--List
	select nciviewid, Shorttitle as [Short Title], 
		(select top 1 currenturl from dbo.prettyurl p where p.nciviewid = b.nciviewid order by isprimary desc, isroot desc) as [Pretty URL]
		, listid as objectid,  listname as [Object Title], type as [Object Type], previewLive
		from
		(
			select v.nciviewid, shortTitle, nciviewobjectid, listid,  listname, type, sum(previewLive) as previewlive
			from
				(
					select 
						vo.nciviewid, vo.nciviewobjectid, l.listid, l.listname, vo.type, 1 as previewLive
					from dbo.listitem li inner join dbo.viewobjects vo on vo.objectid = li.listid
					inner join dbo.list l on l.listid = li.listid
					where li.nciviewid = @nciviewid
					and vo.nciviewid not in (select nciviewid from cancergov.dbo.viewproperty where propertyname = 'redirecturl')
					and vo.nciviewid not in (select nciobjectid from cancergov.dbo.nciobjects where ObjectType ='leftNav')
					union all
					select 
						vo.nciviewid, vo.nciviewobjectid,  l.listid,l.listname, vo.type, 2 as previewLive
					from cancergov.dbo.listitem li inner join cancergov.dbo.viewobjects vo on vo.objectid = li.listid
					inner join cancergov.dbo.list l on l.listid = li.listid
					where li.nciviewid = @nciviewid
					and vo.nciviewid not in (select nciviewid from cancergov.dbo.viewproperty where propertyname = 'redirecturl')
					and vo.nciviewid not in (select nciobjectid from cancergov.dbo.nciobjects where ObjectType ='leftNav')
				) a
				inner join dbo.nciview v on v.nciviewid = a.nciviewid
			group by v.nciviewid, shortTitle, nciviewobjectid, listid,  listname, type
			) b 
		
--HTML 
	union all
	select v.nciviewid, v.shortTitle,
	(select top 1 currenturl from dbo.prettyurl p where p.nciviewid = v.nciviewid order by isprimary desc, isroot desc) as PrettyURL
	, documentid, b.title, type, previewlive
	from
	(
		select nciviewid, documentid,  title, type, sum(previewlive) as previewLive
		from
		(
		select  
		  vo.nciviewid, documentid, d.title, type, 1 as previewLive
		from dbo.document d inner join dbo.prettyurl p on (d.data like '%"'+isnull(currenturl, proposedurl) +'%' or d.data like '%cancer.gov'+isnull(currenturl, proposedurl) +'%')
		inner join dbo.viewobjects vo on vo.objectid = d.documentid
		and vo.nciviewid not in (select nciviewid from dbo.viewproperty where propertyname = 'redirecturl')
		and vo.nciviewid not in (select nciobjectid from cancergov.dbo.nciobjects where ObjectType ='leftNav')
		where p.nciviewid = @nciviewid
		union all
		select  
		  vo.nciviewid, documentid,  d.title, type, 2 as previewLive
		from cancergov.dbo.document d inner join cancergov.dbo.prettyurl p on (d.data like '%"'+currenturl +'%' or d.data like '%cancer.gov'+currenturl +'%')
		inner join cancergov.dbo.viewobjects vo on vo.objectid = d.documentid
		and vo.nciviewid not in (select nciviewid from cancergov.dbo.viewproperty where propertyname = 'redirecturl')
		and vo.nciviewid not in (select nciobjectid from cancergov.dbo.nciobjects where ObjectType ='leftNav')
		where p.nciviewid = @nciviewid
		) a
		group by nciviewid, documentid,  title,type
	) b
	inner join dbo.nciview v on v.nciviewid = b.nciviewid
--Digest
	union all
	select 
		nciviewid, Shorttitle, 
		(select top 1 currenturl from dbo.prettyurl p where p.nciviewid = b.nciviewid order by isprimary desc, isroot desc) as PrettyURL
		,listID, listName ,  type,  previewLive
	from
	(
		select 	 nciviewid, Shorttitle, listID, listName ,  type,  sum(previewLive) as previewlive
		from
			(
			select
			v.nciviewid, v.Shorttitle,  l.listID, l.listName , 'list' as type, 1 as previewLive
			from dbo.nciview v inner join dbo.ncitemplate t on v.ncitemplateid = t.ncitemplateid
			inner join dbo.viewobjects vo on vo.nciviewid = v.nciviewid
			inner join dbo.viewobjectproperty vop on vop.nciviewobjectid = vo.nciviewobjectid
			inner join dbo.list l on l.Parentlistid = vop.propertyvalue
			inner join dbo.listItem li on li.listid = l.listid
			where t.name = 'digestpage' and  propertyname = 'digestrelatedlistid'
			and li.nciviewid = @nciviewid
			and v.nciviewid not in (select nciviewid from cancergov.dbo.viewproperty where propertyname = 'redirecturl')
			union all
			select 
			v.nciviewid, v.Shorttitle,  l.listID, l.listName , 'list' as type, 2 as previewLive
			from cancergov.dbo.nciview v inner join cancergov.dbo.ncitemplate t on v.ncitemplateid = t.ncitemplateid
			inner join cancergov.dbo.viewobjects vo on vo.nciviewid = v.nciviewid
			inner join cancergov.dbo.viewobjectproperty vop on vop.nciviewobjectid = vo.nciviewobjectid
			inner join cancergov.dbo.list l on l.Parentlistid = vop.propertyvalue
			inner join cancergov.dbo.listItem li on li.listid = l.listid
			where t.name = 'digestpage' and  propertyname = 'digestrelatedlistid'
			and li.nciviewid = @nciviewid
			and v.nciviewid not in (select nciviewid from cancergov.dbo.viewproperty where propertyname = 'redirecturl')
			) a
			group by  nciviewid, Shorttitle, listID, listName ,  type
	)b

	Order by type



END 
GO

Grant execute on dbo.usp_getLinkToPage to webadminUser_role
