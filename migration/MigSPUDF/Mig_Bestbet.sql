drop procedure dbo.mig_BestbetCategory
go
create procedure dbo.mig_BestbetCategory
as
select 
catname as category_name
, weight as category_weight
, isExactmatch as exact_match
, case isSpanish when  1 then 'es_us' else 'en_us' END as sys_lang
from bestbetcategories 
go

drop function dbo.mig_bestbetListItem
go
create function dbo.mig_bestbetListItem
(@catname varchar(255))
	returns @r table 
	(catname varchar(255), Slot varchar(150), [snippet template] varchar(200)
	, nciviewid varchar(80), [content type] varchar(300), priority int)
as
BEGIN
	insert into @r
	--External link
	select bc.catName, 
		'cgvBestBetsListItems' as slot,
		'cgvSnBestBetsListItem' as [snippet template],
		convert(varchar(80), li.nciviewid) as nciviewid
		, 'nciLink' as [content type]
		, li.priority
		from cancergovstaging.dbo.listitem li inner join cancergovstaging.dbo.bestbetcategories bc 
					on li.listid = bc.listid
		where catname = @catname and 
		li.nciviewid in (select nciviewid from nciview where ncitemplateid is null)
		union
		--normal
		select bc.catName, 
		'cgvBestBetsListItems' as slot,
		'cgvSnBestBetsListItem' as [snippet template],
		convert(varchar(80), li.nciviewid) as nciviewid
		, (select top 1 [page content type] from migmap m where m.nciviewid = li.nciviewid) as [content type]
		, li.priority
		from cancergovstaging.dbo.listitem li inner join cancergovstaging.dbo.bestbetcategories bc 
					on li.listid = bc.listid
		where 	li.nciviewid in (select nciviewid from migmap)
			and catname = @catname
		union 
		--microsite
		select bc.catName, 
		'cgvBestBetsListItems' as slot,
		'cgvSnBestBetsListItem' as [snippet template],
		convert(varchar(80), li.nciviewid) as nciviewid
			,
		(select top 1 [content type] from microsites s where s.nciviewid = li.nciviewid and [content type] <> 'ncilist' order by priority) as [content type] 
		, li.priority
		from cancergovstaging.dbo.listitem li inner join cancergovstaging.dbo.bestbetcategories bc 
					on li.listid = bc.listid
			where li.nciviewid in (select nciviewid from microsites)
				and catname = @catname 
		--summary
		union
		select bc.catName, 
		'cgvBestBetsListItems' as slot,
		'pdqSnCancerInformationSummaryLink' as [snippet template],
		dbo.mig_getcdrid(li.nciviewid)
		, 'pdqCancerInfoSummaryLink' as [content type]
		, li.priority
		from cancergovstaging.dbo.listitem li inner join cancergovstaging.dbo.bestbetcategories bc 
					on li.listid = bc.listid
		where catname = @catname 

		and li.nciviewid in 
		(select nciviewid from nciview where ncitemplateid in (select ncitemplateid from dbo.ncitemplate where name = 'summary'))
		--Drug info summary
		union
		select bc.catName, 
		'cgvBestBetsListItems' as slot,
		'cgvSnBestBetsListItem' as [snippet template],
		dbo.mig_getcdrid(li.nciviewid)
		, 'pdqDrugInfoSummary' as [content type]
		, li.priority
		from cancergovstaging.dbo.listitem li inner join cancergovstaging.dbo.bestbetcategories bc 
					on li.listid = bc.listid
		where catname = @catname 
		
		and li.nciviewid in 
		(select nciviewid from nciview where ncisectionid in 
			(select ncisectionid from dbo.ncisection where name = 'druginfo')
			and updateuserid = 'gatekeeper')
		--redirect etc.
		union
		select bc.catName, 
		'cgvBestBetsListItems' as slot,
		'cgvSnBestBetsListItem' as [snippet template],
		convert(varchar(80), li.nciviewid)
		, NULL as [content type]
		, li.priority
		from cancergovstaging.dbo.listitem li inner join cancergovstaging.dbo.bestbetcategories bc 
					on li.listid = bc.listid
		where catname = @catname 
		and li.nciviewid not in (select nciviewid from migmapall)
		and li.nciviewid not in 
		(select nciviewid from nciview where ncisectionid in 
			(select ncisectionid from dbo.ncisection where name = 'druginfo')
			and updateuserid = 'gatekeeper')
		and li.nciviewid not in 
		(select nciviewid from nciview where ncitemplateid in (select ncitemplateid from dbo.ncitemplate where name = 'summary'))
		and li.nciviewid not in
		(select nciviewid from nciview where ncitemplateid is null)
	return
END
GO

drop function dbo.mig_bestbetsynonyms
go
create function dbo.mig_bestbetsynonyms
(@catname varchar(255))
	returns @r table 
	(catname varchar(255), name varchar(50), is_exact_match bit
	, notes varchar(50))
as
BEGIN
	insert into @r
		select bc.catName, 
		s.synName as name,
		s.IsExactMatch as is_exact_match,
		case when len(s.notes) > 0 then s.notes else NULL end as notes
		from bestbetsynonyms s inner join cancergovstaging.dbo.bestbetcategories bc 
		on s.categoryid = bc.categoryid
		where IsNegated = 0
			and catname = @catname 
	return
END
GO

drop function dbo.mig_bestbetNegated_synonyms
go
create function dbo.mig_bestbetNegated_synonyms
(@catname varchar(255))
	returns @r table 
	(catname varchar(255), negated_name varchar(50), negated_is_exact_match bit
	, negated_notes varchar(50))
as
BEGIN
	insert into @r
		select bc.catName, 
		s.synName as name,
		s.IsExactMatch as is_exact_match,
		case when len(s.notes) > 0 then s.notes else NULL end as notes
		from bestbetsynonyms s inner join cancergovstaging.dbo.bestbetcategories bc 
		on s.categoryid = bc.categoryid
		where IsNegated = 1
			and catname = @catname 
	return
END
GO




