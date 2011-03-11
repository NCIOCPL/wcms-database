drop view MSurltree
go
create view MSurlTree
as
select top 100 percent p.currenturl, u.*
from 
(select  folder + case when urlname is null then '' else '/'+ urlname END
as currenturl
from microsites) p 
cross apply dbo.prettyurl_split(p.currenturl) as u
order by currenturl

GO

GO
drop procedure Mig_folder
go
create procedure Mig_folder
as
BEGIN
	create table #t (urlpath varchar(500), type varchar(100))

	insert into #t
	select urlpath, 'folder' as type
	from urltree
	where isend = 0
	group by urlpath
	union 
	select primaryurl, 'PageFolder' as type
	from migpage
	where nciviewid in
		(
		select nciviewid
		from  viewobjects vo
		where type  in ('document', 'include', 'list', 'hdrlist', 'search', 'txtinclude', 'NavDoc')
		and objectid not in (select objectid from migmap m where m.nciviewid = vo.nciviewid and slot = 'cgvRelatedPages')
		group by nciviewid
		having count(*) > 1
		)
		and nciviewid not in 
			(select nciviewid from viewproperty 
					where propertyname = 'tag' and propertyvalue = 'Private Archive'
				)
	union 
	select '/homepage', 'PageFolder' as type
	union all
	select '/PrivateArchive', 'folder' as type
	union all
	select '/SharedItems', 'folder' as type
	union all
	select '/SharedItems/ContentHeaders', 'folder' as type
	union all
	select '/SharedItems/Links', 'folder' as type
	union all
		select '/SharedItems/ContentBlocks', 'folder' as type
	union all
		select '/SharedItems/Lists', 'folder' as type
	union all
		select '/SharedItems/SiteBanner', 'folder' as type
	union all
		select '/SharedItems/SiteFooter', 'folder' as type
	union all
		select '/SharedItems/Tiles', 'folder' as type
	union all
		select '/SharedItems/PageOptions', 'folder' as type
	union all
			select '/Files/PDF', 'folder' as type
	union all
			select '/Files/Powerpoint', 'folder' as type
	union all
			select '/Files/Excel', 'folder' as type
	union all
			select '/BestBets', 'folder' as type
	union all
			select '/global/RSS', 'folder' as type
	union all
			select '/SharedItems/ApplicationModules', 'folder' as type
	union all
			select distinct dbo.mig_DPGetFolder(prettyurl) ,'DP'
			from migmap m inner join nciview v on v.nciviewid = m.nciviewid
			where [cancergov template] ='digestpage'
			and dbo.mig_DPGetFolder(prettyurl) like '%/main'

	update #t
	set type = 'MixFolder'	
	where urlpath in
	(
	select t.urlpath from #t t inner join #t t1 
	on t.urlpath = t1.urlpath and t.type <> t1.type
	)
	and type = 'Folder'

	delete from #t
	where urlpath in
	(
	select t.urlpath from #t t inner join #t t1 
	on t.urlpath = t1.urlpath and t.type <> t1.type
	)
	and type = 'pageFolder'




	insert into #t
	select urlpath, 'microsite'
	from MSurltree
	where isend = 0
	group by urlpath


	insert into #t values ('/aboutnci/occp/overview', 'microsite')

insert into #t  values('/aboutnci/occp/ncipartnersinchina', 'microsite')
insert into #t  values('/aboutnci/occp/fundingopportunities', 'microsite')
insert into #t  values('/aboutnci/occp/activities', 'microsite')
insert into #t  values('/aboutnci/occp/contact', 'microsite')
insert into #t  values('/aboutnci/organization/olacpd/collaboration', 'microsite')
insert into #t  values('/aboutnci/organization/olacpd/training', 'microsite')
insert into #t  values('/aboutnci/organization/olacpd/researchnetwork', 'microsite')
insert into #t  values('/aboutnci/organization/olacpd/activities', 'microsite')
insert into #t  values('/aboutnci/organization/olacpd/about', 'microsite')
insert into #t  values('/aboutnci/recovery/recoveryfunding/awards', 'microsite')
insert into #t  values('/aboutnci/recovery/recoverynews/ncinewsarchive', 'microsite')
insert into #t  values('/aboutnci/recovery/recoverynews/highlightsarchive', 'microsite')
insert into #t  values('/aboutnci/recovery/recoveryobjectives', 'microsite')
insert into #t  values('/aboutnci/servingpeople/highlights', 'microsite')
insert into #t  values('/cancertopics/aya/coping', 'microsite')
insert into #t  values('/cancertopics/aya/reports', 'microsite')
insert into #t  values('/cancertopics/aya/resources', 'microsite')
insert into #t  values('/cancertopics/aya/survivorship', 'microsite')
insert into #t  values('/cancertopics/aya/treatment', 'microsite')
insert into #t  values('/cancertopics/aya/types', 'microsite')
insert into #t  values('/cancertopics/cancerlibrary/cancerspace/howitworks', 'microsite')
insert into #t  values('/cancertopics/cancerlibrary/cancerspace/questions', 'microsite')
insert into #t  values('/clinicaltrials/conducting/ncictrp/who-registers', 'microsite')
insert into #t  values('/clinicaltrials/conducting/ncictrp/how-to-register', 'microsite')
insert into #t  values('/aboutnci/organization/olacpd/advancing', 'microsite')



	select distinct urlpath , '' as type from #t
	order by urlpath
	

END
GO