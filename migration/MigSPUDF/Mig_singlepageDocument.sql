drop procedure Mig_SinglePageDocument 
go
create procedure Mig_SinglePageDocument 
as
BEGIN

			
			 select m.nciviewid as viewid, [page content type],
				vo.objectid, 'bodyfield' as field, isnull(data,'') as bodyfield  , priority , 
			NULL as [snippet content type], 
			NULL as [Snippet Template], 
			NULL as long_title
						from viewobjects vo inner join document d on d.documentid = vo.objectid
						inner join migmap m on m.nciviewid = vo.nciviewid and m.objectid = vo.objectid
						where [cancergov template] <> 'digestpage'
						and [page content type] in (
											'cgvClinicalTrialResult',
											'cgvDrugInfoSummary',
											'cgvFactSheet',
											'cgvFeaturedClinicalTrial',
											'cgvPressRelease',
											'nciGeneral',
											'nciHome',
											'cgvCancerTypeHome',
											'nciLandingPage')
					and 
						(priority =
						(select min(priority) 
								from viewobjects vo inner join document d on d.documentid = vo.objectid 
								where vo.nciviewid = m.nciviewid and vo.type <> 'search'
							)
							or 
							priority is null)

					and [snippet content type] <> 'nciform'
					and vo.type <> 'search'

					union all

					select 
						m.nciviewid as viewid, [page content type],
						vo.objectid, 'cgvbody' as slot, isnull(data,'')  , priority, 'nciDocFragment', 'cgvSnBody', d.title
						from viewobjects vo inner join document d on d.documentid = vo.objectid
						inner join migmap m on m.nciviewid = vo.nciviewid and m.objectid = vo.objectid
						where [cancergov template] <> 'digestpage'
						and [page content type] in (
											'cgvClinicalTrialResult',
											'cgvDrugInfoSummary',
											'cgvFactSheet',
											'cgvFeaturedClinicalTrial',
											'cgvPressRelease',
											'nciGeneral',
											'nciHome',
											'cgvCancerTypeHome',
											'nciLandingPage')
					and priority >(select min(priority) 
								from viewobjects vo inner join document d on d.documentid = vo.objectid 
								where vo.nciviewid = m.nciviewid and vo.type <> 'search'
							)
					and [snippet content type] <> 'nciform'
					and vo.type <> 'search'

					union all			

					select 
						m.nciviewid as viewid, [page content type],
						vo.objectid, 'cgvbody' as slot, isnull(data,'')  , priority ,'nciform', [snippet template],d.title
						from viewobjects vo inner join document d on d.documentid = vo.objectid
						inner join migmap m on m.nciviewid = vo.nciviewid and m.objectid = vo.objectid
						where [cancergov template] <> 'digestpage'
						and [page content type] in (
											'cgvClinicalTrialResult',
											'cgvDrugInfoSummary',
											'cgvFactSheet',
											'cgvFeaturedClinicalTrial',
											'cgvPressRelease',
											'nciGeneral',
											'nciHome',
											'cgvCancerTypeHome',
											'nciLandingPage')
						and [snippet content type] = 'nciform'

	
END

