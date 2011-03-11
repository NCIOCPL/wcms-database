drop procedure dbo.mig_viewobjects
go
create procedure dbo.mig_viewobjects
as
BEGIN
--singlepagecontent
		select  m.nciviewid as viewid, [page content type],
		priority, --viewobjecttype, 
		m.objectid, [Snippet Content Type], 
		 slot ,   [Snippet Template]
		 from migmapall m inner join viewobjects vo 
		on m.objectid = vo.objectid and m.nciviewid = vo.nciviewid
		where 
		[page content type] in (  
         'cgvClinicalTrialResult',  
         'cgvDrugInfoSummary',  
         'cgvFactSheet',  
         'cgvFeaturedClinicalTrial',  
         'cgvPressRelease',  
         'nciGeneral',  
         'nciHome',  
         'cgvCancerTypeHome',  
         'nciLandingPage') 
		and slot not in ('cgvContentHeader', 'cgvRelatedPages', 'NA')
		and m.objectid not in (select documentid from document)
		and [cancergov template] <> 'digestpage'
		and m.objectid in (select listid from list)
				
	union all
		select  m.nciviewid as viewid, [page content type],
		priority, --viewobjecttype, 
		m.objectid, 'nciDocFragment' as [Snippet Content Type], 
		 'cgvBody' as slot ,  'cgvSnBody' as [Snippet Template]
		 from migmapmicrosites m inner join viewobjects vo 
		on m.objectid = vo.objectid and m.nciviewid = vo.nciviewid
		where 
		[cancergov template] in ( 'singlepagecontent', 'INCLUDE', 'CancerTypeHomepage')
		and slot not in ('cgvContentHeader', 'cgvRelatedPages')
		and priority >
						(select min(priority) 
								from viewobjects vo inner join document d on d.documentid = vo.objectid 
								where vo.nciviewid = m.nciviewid and vo.type <> 'search'
							)
		and [snippet content type] <> 'nciform'
		and vo.type <> 'search'
		and m.objectid in (select documentid from document)
	union all
		select  m.nciviewid as viewid, [page content type],
		priority, --viewobjecttype, 
		m.objectid, 'nciDocFragment' as [Snippet Content Type], 
		 'cgvBody' as slot ,  'cgvSnBody' as [Snippet Template]
		 from migmap m inner join viewobjects vo 
		on m.objectid = vo.objectid and m.nciviewid = vo.nciviewid
		where 
		[page content type] in (  
         'cgvClinicalTrialResult',  
         'cgvDrugInfoSummary',  
         'cgvFactSheet',  
         'cgvFeaturedClinicalTrial',  
         'cgvPressRelease',  
         'nciGeneral',  
         'nciHome',  
         'cgvCancerTypeHome',  
         'nciLandingPage')  
		and slot not in ('cgvContentHeader', 'cgvRelatedPages')
		and priority >
						(select min(priority) 
								from viewobjects vo inner join document d on d.documentid = vo.objectid 
								where vo.nciviewid = m.nciviewid and vo.type <> 'search'
							)
		and [snippet content type] <> 'nciform'
		and vo.type <> 'search'
		and m.objectid in (select documentid from document)
	Union all
		select
		m.nciviewid as viewid, [page content type],
		priority, --viewobjecttype, 
		m.objectid, 'nciform' as [Snippet Content Type], 
		 'cgvBody' as slot ,  [Snippet Template]
			 from viewobjects vo inner join document d on d.documentid = vo.objectid  
			inner join migmapall m on m.nciviewid = vo.nciviewid and m.objectid = vo.objectid  
			where  [cancergov template] in ( 'singlepagecontent', 'INCLUDE') and [snippet content type] = 'nciform'  



order by 1, priority

END



