drop procedure Mig_StaticContentRelationships  
go
create procedure Mig_StaticContentRelationships  
as  
BEGIN  
 select    
  viewid,   
  OwnerContentType,  
  ObjectID,  
  DependentContentType,  
  Slot,  
  SnippetTemplate  
 from MigStaticContentRelationships  
END  
go

drop procedure dbo.Mig_sharedNavList
go
create procedure dbo.Mig_sharedNavList
as
BEGIN
	select listname as list_title, listdesc as list_description 
	, listid as objectid
	from list l 
	where listid in (select listid from uniquelist)	
	or listid = 'D9C12B16-3C19-44A6-AFA9-4D61D25B64DB'
END
GO

drop function dbo.Mig_NavlistItem
go
create function dbo.Mig_NavlistItem(@listid uniqueidentifier)
returns @r table (listid uniqueidentifier, viewid uniqueidentifier, slot varchar(200),
	[content type] varchar(800), template varchar(800), priority int)
as
BEGIN

insert into @r

	--nciLink
	select li.listid, li.nciviewid,   
	  'cgvLeftNavListItems' as Slot, 
		case when exists (select top 1 [page content type] 
			from dbo.migmap m1 where m1.nciviewid = li.nciviewid) 
			then (select top 1 [page content type] 
			from dbo.migmap m1 where m1.nciviewid = li.nciviewid) 
			when exists (select top 1 * from nciview v where v.nciviewid = li.nciviewid
							and ncitemplateid is null)
				then 'nciLink'
			ELSE
				NULL
			END
		as [content type]  
	 , case ul.descdisplay when 1 then 'cgvSnQuickLinksListItemWithDesc' 
		else 'cgvSnQuickLinksListItemNoDesc' END  as template  
	 , priority  
	from listitem li inner join  uniquelist ul on li.listid = ul.listid
	where listname <> 'NCI Highlights'
	and li.listid = @listid
	and li.nciviewid not in (select nciviewid from microsites)
	union all
	select li.listid, li.nciviewid,   
	  'cgvLeftNavListItems' as Slot, 
		case when exists (select top 1 [page content type] 
			from dbo.migmap m1 where m1.nciviewid = li.nciviewid) 
			then (select top 1 [page content type] 
			from dbo.migmap m1 where m1.nciviewid = li.nciviewid) 
			when exists (select top 1 * from nciview v where v.nciviewid = li.nciviewid
							and ncitemplateid is null)
				then 'nciLink'
			ELSE
				NULL
			END
		as [content type]  
	 , case ul.descdisplay when 1 then 'cgvSnHighlightsListItemWithDesc' 
		else 'cgvSnHighlightsListItemNoDesc' END  as template  
	 , priority  
	from listitem li inner join  uniquelist ul on li.listid = ul.listid
	where listname = 'NCI Highlights'
	and li.listid = @listid
	and li.nciviewid not in (select nciviewid from microsites)
	union 
	--rightNav for druginforsummary
	select li.listid, li.nciviewid, 
	'cgvRightNav' as slot,
	case when exists (select top 1 [page content type] 
			from dbo.migmap m1 where m1.nciviewid = li.nciviewid) 
			then (select top 1 [page content type] 
			from dbo.migmap m1 where m1.nciviewid = li.nciviewid) 
			when exists (select top 1 * from nciview v where v.nciviewid = li.nciviewid
							and ncitemplateid is null)
				then 'nciLink'
			ELSE
				NULL
			END
		as [content type]  
		,  'cgvSnQuickLinksListItemNoDesc'  as template  
	 , priority 
	from listitem li
	where listid = 'D9C12B16-3C19-44A6-AFA9-4D61D25B64DB'
	and listid = @listid
	--Microsit Index
	union
	select a.listid, m.viewid, 
	'cgvLeftNavListItems' as Slot, 
	'cgvMicrositeIndex' as [content type]
	 , case a.descdisplay when 1 then 'cgvSnQuickLinksListItemWithDesc' 
			else 'cgvSnQuickLinksListItemNoDesc' END  as template 
		, li.priority
	from uniquelist a inner join listitem li on a.listid = li.listid
	inner join prettyurl p on p.nciviewid = li.nciviewid
	inner join MSmicrositeindex m  on p.currenturl = m.folder
		where listname <> 'NCI Highlights'
	and a.listid = @listid
	union
	select a.listid, m.viewid, 
	'cgvLeftNavListItems' as Slot, 
	'cgvMicrositeIndex' as [content type]
	 , case a.descdisplay when 1 then 'cgvSnHighlightsListItemWithDesc' 
			else 'cgvSnHighlightsListItemNoDesc' END  as template  
		, li.priority
	from uniquelist a inner join listitem li on a.listid = li.listid
	inner join prettyurl p on p.nciviewid = li.nciviewid
	inner join MSmicrositeindex m  on p.currenturl = m.folder
		where listname = 'NCI Highlights'
	and a.listid = @listid


return
END
GO
--select * from  dbo.Mig_NavlistItem ('D9C12B16-3C19-44A6-AFA9-4D61D25B64DB') order by priority

drop procedure dbo.Mig_sharedTile
go
create procedure dbo.Mig_sharedTile
as
BEGIN
	select i.imageid as objectid, i.imagename as long_title, i.imagealttext as img_alt,
	i.width as img1_width , i.height as img1_height, i.url, imagesource
	 from uniqueimage ui inner join image i on ui.imageid = i.imageid
END
GO


drop procedure dbo.Mig_NavList
GO

create procedure dbo.Mig_NavList
as
BEGIN
	select distinct s.sectionPathid as viewid,-- s.subtype,
	case  when s.subtype =  'section'  then 'rffNavon'
		when (s.subtype = 'sectiontopage' or s.subtype = 'page')  
		and exists (select top 1 * from migmap m where m.nciviewid = s.sectionpathid )
		then (select top 1 [page content type] from migmap m where m.nciviewid = s.sectionpathid  and [page content type] <> 'rffnavon')
		ELSE 'nciGeneral' END
		as [content type],
	o.map_objectid as objectid, 'cgvLeftNav' as slot, 'cgvSnLeftNavList' as template
	, o.priority 
	from sectionpageleftnav s inner join navobj o on o.nciviewid = s.nciviewid
		where  o.type = 'list'
	union
	select sectionPathid as viewid,
	'rffNavon',
	'D9C12B16-3C19-44A6-AFA9-4D61D25B64DB' as objectid,
	'cgvRightNav' as slot,
	'cgvSnList' as template, 1 as priority
	from sectionpageleftnav
	where [sectionpagetitle] = 'druginfo'
	order by 2, 1, priority
END
GO


drop procedure dbo.Mig_NavTile
go
create procedure dbo.Mig_NavTile
as
BEGIN
	select distinct s.sectionpathid as viewid,
		case  when s.subtype =  'section'  then 'rffNavon'
		when (s.subtype = 'sectiontopage' or s.subtype = 'page')  
		and exists (select top 1 * from migmap m where m.nciviewid = s.sectionpathid )
		then (select top 1 [page content type] from migmap m where m.nciviewid = s.sectionpathid  and [page content type] <> 'rffnavon')
		ELSE 'nciGeneral' END
		as [content type],
	o.map_objectid as objectid,'cgvLeftNav' as slot, 'cgvSnTile' as template
	, o.priority 
	from sectionpageleftnav s inner join navobj o on o.nciviewid = s.nciviewid
		where type = 'image'
	order by 2,1, priority
END
GO

drop procedure dbo.Mig_NavDoc
go
Create procedure dbo.Mig_NavDoc
as
BEGIN
select distinct s.sectionPathid as viewid, 
case  when s.subtype =  'section'  then 'rffNavon'
		when (s.subtype = 'sectiontopage' or s.subtype = 'page')  
		and exists (select top 1 * from migmap m where m.nciviewid = s.sectionPathid )
		then (select top 1 [page content type] from migmap m where m.nciviewid = s.sectionpathid  and [page content type] <> 'rffnavon')
		ELSE 'nciGeneral' END
		as [owner content type],
		o.objectid, 'cgvLeftNav' as slot, 'nciDocFragment' as [dependent content type],
	case dbo.mig_GetShowpagetitle(o.nciviewid, o.objectid) when 1 then 'cgvSnBoxedTitleDocFragLeftNav'
		else 'cgvSnBoxedDocFragLeftNav' END as template
	, convert(varchar(max), d.data) as bodyfield
	, d.title as long_title
	, o.priority 
	from sectionpageleftnav s inner join (select distinct nciviewid , objectid, type, priority from navobj) o on o.nciviewid = s.nciviewid 
		inner join document d on d.documentid = o.objectid
		where type = 'navdoc'
	order by 2,1, priority
END
GO


---------

-------------------
--tabimgname -- > navImage
drop procedure dbo.Mig_Navon
go
create procedure dbo.Mig_Navon
as
	select sectionpathid as viewid, 
	path
	,name as nav_title
	, 'rffNavon' as [content type]
	from section 
	where len(path) > 3
	union all
	select '5A4ACC45-779C-496d-AD81-D2034DCF3D9D' as viewid,
		'/' as path
	, 'Site Root' as nav_title
	, 'rffNavTree' as [content type]
GO

drop procedure dbo.Mig_setlandingpage
go
create procedure dbo.Mig_setlandingpage
as
BEGIN
create table #folder (urlpath varchar(800), type varchar(300))
insert into #folder exec Mig_folder 
	select 
	urlpath,
	(select top 1  nciviewid from prettyurl p 
		where p.currenturl = urlpath)	 as viewid,
	(select top 1 [page content type] 
		from migmap m where m.nciviewid in (select top 1  nciviewid from prettyurl p 
		where p.currenturl = urlpath)) as [content type]
	 ,'rffNavlandingpage'	as slot
	, 'cgvSnTitleLink' as template
	from #folder f 
	where 
(select top 1  nciviewid from prettyurl p 
		where p.currenturl = urlpath) is not null
and (select top 1 [page content type] 
		from migmap m where m.nciviewid in (select top 1  nciviewid from prettyurl p 
		where p.currenturl = urlpath)) is not null
END

GO

---------
----------


drop procedure dbo.Mig_NavObj
go
create procedure dbo.Mig_NavObj
as
BEGIN
		create table #navObj (viewid uniqueidentifier, 
		[content type] varchar(100),
		objectid uniqueidentifier,
		slot varchar(100),
		template varchar(100),
		priority int
		)

		create table #navObj1 (viewid uniqueidentifier, 
		[content type] varchar(100),
		objectid uniqueidentifier,
		slot varchar(100),
		template varchar(100),
		priority int,
		[dependent content type] varchar(100) NULL
		)

		insert into #navobj exec dbo.Mig_navlist
		INSERT INTO #navobj1 
		SELECT *,  'nciList' as [dependent content type] 
		from #navobj
		
		delete from #navobj
	
		insert into #navobj exec dbo.Mig_navTile
		INSERT INTO #navobj1 SELECT *,  'nciTile' as [dependent content type] 
		from #navobj
	
	
		insert into #navobj1
		select distinct s.sectionpathid as viewid, 
		case  when s.subtype =  'section'  then 'rffNavon'
				when (s.subtype = 'sectiontopage' or s.subtype = 'page')  
				and exists (select top 1 * from migmap m where m.nciviewid = s.sectionpathid )
				then (select top 1 [page content type] from migmap m where m.nciviewid = s.sectionpathid  and [page content type] <> 'rffnavon')
				ELSE 'nciGeneral' END
				as [content type],
				o.objectid, 'cgvLeftNav' as slot,
			case dbo.mig_GetShowpagetitle(o.nciviewid, o.objectid) when 1 then 'cgvSnBoxedTitleDocFragLeftNav'
				else 'cgvSnBoxedDocFragLeftNav' END as template
			, o.priority 
			, 'nciDocFragment' as [dependent content type]
			from sectionpageleftnav s inner join (select distinct nciviewid, objectid, type, priority from navobj) o on o.nciviewid = s.nciviewid
				inner join document d on d.documentid = o.objectid
				where type = 'navdoc'



		insert into #navobj1
		select distinct
		n.sectionpathid as viewid, 'rffNavon'as [content type],
		objectid,
		'cgvLeftNav' as slot , 'cgvSnAppWidget' as template
		,priority
		, 'nciAppWidget' as [dependent content type]
		from viewobjects vo inner join sectionpageleftnav n
		on vo.nciviewid = n.nciviewid
		where type like '%search%'
	


		-------------- add page option box
		select distinct  viewid , 
		[content type] ,
		objectid ,
		slot ,
		template ,
		priority ,
		[dependent content type]
		 from #navobj1
		union all
		-- Spanish position 2
		select distinct viewid, [content type], 
		'0A1ED33B-7F61-434F-8B7B-7CA76119277B' as objectid, slot, 
		'cgvSnPageOptionsBox' as template, 
			0.5 + (select min(priority) 
					from #navobj1 sn 
					where sn.viewid = n.viewid), 
		'cgvPageOptionsBox' as [dependent content type]
		from #navobj1 n
		where [content type] = 'rffnavon'
			and viewid in 
		(select sectionpathid 
		from sectionpageleftnav where sectionpagetitle 
				in ('Spanish Cancer',
					'Spanish Cancer Types',
					'Spanish Fact Sheets',
					'Spanish Support & Resources'
					)
		)
		union all
		-- Spanish position 1
		select distinct viewid, [content type], 
		'0A1ED33B-7F61-434F-8B7B-7CA76119277B' as objectid, slot, 
		'cgvSnPageOptionsBox' as template, 
			0 as priority, 
		'cgvPageOptionsBox' as [dependent content type]
		from #navobj1 n
		where [content type] = 'rffnavon'
			and viewid in 
			(select sectionpathid 
			from sectionpageleftnav where sectionpagetitle 
					in ('Spanish About NCI',
						'Spanish Bulletin',
						'Spanish Home',
						'Spanish News',
						'Spanish Recovery',
						'Spanish Redesigned Bulletin'
					)
			)

		union all
		-- English position 1
		select distinct viewid, [content type], 
			'EDE35B9D-D1C0-4D5F-9E27-90F45613F827' as objectid, slot, 
			'cgvSnPageOptionsBox' as template, 
				0 as priority, 
			'cgvPageOptionsBox' as [dependent content type]
			from #navobj1 n
			where [content type] = 'rffnavon'
				and viewid in 
			(select sectionpathid 
			from sectionpageleftnav where sectionpagetitle not like 'spanish%'
				and sectionpagetitle <> 'NewsCenter'
			)
					
		union all
		-- English position 2
		select distinct viewid, [content type], 
		'EDE35B9D-D1C0-4D5F-9E27-90F45613F827' as objectid, slot, 
		'cgvSnPageOptionsBox' as template, 
			0.5 + (select min(priority) 
					from #navobj1 sn 
					where sn.viewid = n.viewid)
			 as priority, 
		'cgvPageOptionsBox' as [dependent content type]
		from #navobj1 n
		where [content type] = 'rffnavon'
			and viewid in 
		(select sectionpathid 
		from sectionpageleftnav 
		where sectionpagetitle = 'NewsCenter'
		)

		union all
			-- no Navobj, except pageoptionbox
		select distinct
			 sectionpathid, --'92D08A61-C544-43D5-B48B-BD49EF0F4F80',
			'rffNavon',	
			'EDE35B9D-D1C0-4D5F-9E27-90F45613F827' as objectid,
			'cgvLeftNav',	'cgvSnPageOptionsBox',	0,	'cgvPageOptionsBox'
			from sectionpageleftNav
			where sectionpagetitle not like '%spanish%'
			and sectionpathid not in
			(select viewid from #navobj1)
		order by 1, priority
		
END
GO
	


