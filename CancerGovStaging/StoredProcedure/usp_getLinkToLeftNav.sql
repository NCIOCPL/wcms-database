if object_id('usp_getLinkToLeftNav') is not NULL
drop procedure dbo.usp_getLinkToLeftNav
GO
Create procedure dbo.usp_getLinkToLeftNav (@nciviewid uniqueidentifier)
as
BEGIN
	set nocount on

	select v.nciviewid, v.shortTitle as [Short Title], listid as objectID, listName as [Object Title], vo.Type as [Object Type], previewLive
			from
			(
			select nciviewobjectID, listid, listname,  nciviewid,  sum(previewlive) as previewLive
			from 
			(
				select vo.nciviewobjectID, li.listid, l.listName,  li.nciviewid,  1 as previewlive
				from dbo.viewobjects vo 
				inner join dbo.nciobjects o on o.parentnciobjectid = vo.objectid
				inner join dbo.list l on l.listid = o.nciobjectid
				inner join dbo.listitem li on li.listid = l.listid
				where vo.nciviewid in (select nciobjectid from dbo.nciobjects where ObjectType ='leftNav')
				and li.nciviewid = @nciviewid
				and vo.nciviewid not in (select nciviewid from dbo.viewproperty where propertyname = 'redirecturl')
				union all
				select vo.nciviewobjectID, li.listid,  l.listName,  li.nciviewid,  2 as previewlive
				from cancergov.dbo.viewobjects vo 
				inner join cancergov.dbo.nciobjects o on o.parentnciobjectid = vo.objectid
				inner join cancergov.dbo.list l on l.listid = o.nciobjectid
				inner join cancergov.dbo.listitem li on li.listid = l.listid
				where vo.nciviewid in (select nciobjectid from cancergov.dbo.nciobjects where ObjectType ='leftNav')
				and li.nciviewid = @nciviewid
				and vo.nciviewid not in (select nciviewid from cancergov.dbo.viewproperty where propertyname = 'redirecturl')
				)a
			group by nciviewobjectID, listid,  listName,  nciviewid
			)b
			inner join dbo.viewobjects vo on vo.nciviewobjectid = b.nciviewobjectid
			inner join dbo.nciview v on v.nciviewid  = vo.nciviewid
	union all
	select v.nciviewid, v.shortTitle, documentid, b.title,  type,  previewlive
		from
		(
			select nciviewid, documentid,  title, type, sum(previewlive) as previewLive
			from
			(
			select  
			  vo.nciviewid, documentid, d.title, type, 1 as previewLive
			from dbo.document d inner join dbo.prettyurl p on (d.data like '%"'+isnull(currenturl, proposedurl) +'%' or d.data like '%cancer.gov'+isnull(currenturl, proposedurl) +'%')
			inner join dbo.viewobjects vo on vo.objectid = d.documentid
			where p.nciviewid = @nciviewid 
				and vo.nciviewid in (select nciobjectid from dbo.nciobjects where ObjectType ='leftNav')
				and vo.nciviewid not in (select nciviewid from dbo.viewproperty where propertyname = 'redirecturl')
			union all
			select  
			  vo.nciviewid, documentid,  d.title, type, 2 as previewLive
			from cancergov.dbo.document d inner join cancergov.dbo.prettyurl p on (d.data like '%"'+currenturl +'%' or d.data like '%cancer.gov'+currenturl +'%')
			inner join cancergov.dbo.viewobjects vo on vo.objectid = d.documentid
			where p.nciviewid = @nciviewid
				and vo.nciviewid in (select nciobjectid from cancergov.dbo.nciobjects where ObjectType ='leftNav')
				and vo.nciviewid not in (select nciviewid from cancergov.dbo.viewproperty where propertyname = 'redirecturl')

			) a
			group by nciviewid, documentid,  title,type
		) b
		inner join dbo.nciview v on v.nciviewid = b.nciviewid



END 
GO

Grant execute on dbo.usp_getLinkToLeftNav to webadminUser_role
