
create table #t (url varchar(250), channel varchar(250), suite varchar(250), [content-group] varchar(250))
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov', 'NCI Homepage', 'nciglobal, ncienglish-all', 'NCI Homepage')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/search/results', 'Search', 'nciglobal, ncienglish-all', 'Global Search')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/about-cancer', 'About Cancer', 'nciglobal, ncienglish-all, ncicancertopics', 'About Cancer (Other)')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/about-cancer/what-is-cancer', 'About Cancer', 'nciglobal, ncienglish-all, ncicancertopics', 'What is Cancer')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/about-cancer/treatment', 'About Cancer', 'nciglobal, ncienglish-all, ncicancertopics', 'Treatment')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/about-cancer/treatment/clinical-trials', 'About Cancer', 'nciglobal, ncienglish-all, nciclinicaltrials', 'Clinical Trials')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/about-cancer/causes-prevention', 'About Cancer', 'nciglobal, ncienglish-all, ncicancertopics', 'Causes &amp; Prevention')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/about-cancer/coping', 'About Cancer', 'nciglobal, ncienglish-all, ncicancertopics', 'Coping')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/about-cancer/screening', 'About Cancer', 'nciglobal, ncienglish-all, ncicancertopics', 'Screening')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/about-cancer/advanced-cancer', 'About Cancer', 'nciglobal, ncienglish-all, ncicancertopics', 'Advanced Cancer')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/about-cancer/diagnosis-staging', 'About Cancer', 'nciglobal, ncienglish-all, ncicancertopics', 'Diagnosis &amp; Staging')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/about-cancer/managing-care', 'About Cancer', 'nciglobal, ncienglish-all, ncicancertopics', 'Managing Cancer Care')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/types', 'Cancer Types', 'nciglobal, ncienglish-all, ncicancertopics', 'Cancer Types Landing Page')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/types/by-body-location', 'Cancer Types', 'nciglobal, ncienglish-all, ncicancertopics', 'Cancer Types Listing Page')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/types/common-cancers', 'Cancer Types', 'nciglobal, ncienglish-all, ncicancertopics', 'Cancer Types Listing Page')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/types/childhood-cancers', 'Cancer Types', 'nciglobal, ncienglish-all, ncicancertopics', 'Childhood Cancers')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/types/aya', 'Cancer Types', 'nciglobal, ncienglish-all, ncicancertopics', 'Adolescent and Young Adult Cancers')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/research', 'Research', 'nciglobal, ncienglish-all, nciresearch', 'Research Landing Page')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/research/nci-role', 'Research', 'nciglobal, ncienglish-all, nciresearch', 'NCI Role')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/research/areas', 'Research', 'nciglobal, ncienglish-all, nciresearch', 'Research Areas')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/research/key-initiatives', 'Research', 'nciglobal, ncienglish-all, nciresearch', 'Key Initiatives')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/research/resources', 'Research', 'nciglobal, ncienglish-all, nciresearch', 'R&amp;D Resources')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/research/progress', 'Research', 'nciglobal, ncienglish-all, nciresearch', 'Research Progress')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/grants-training', 'Grants &amp; Training', 'nciglobal, ncienglish-all, nciresearch', 'Grants &amp; Training Landing Page')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/grants-training/grants', 'Grants &amp; Training', 'nciglobal, ncienglish-all, nciresearch', 'Research Projects Grants')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/grants-training/grants-process', 'Grants &amp; Training', 'nciglobal, ncienglish-all, nciresearch', 'NCI Grants Process')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/grants-training/grants-management', 'Grants &amp; Training', 'nciglobal, ncienglish-all, nciresearch', 'NCI Grants Management')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/grants-training/other-funding', 'Grants &amp; Training', 'nciglobal, ncienglish-all, nciresearch', 'Other Funding')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/grants-training/training', 'Grants &amp; Training', 'nciglobal, ncienglish-all, nciresearch', 'Funding for Training')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/news-events', 'News &amp; Events', 'nciglobal, ncienglish-all, ncinews', 'News &amp; Events Landing Page')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/news-events/press-releases', 'News &amp; Events', 'nciglobal, ncienglish-all, ncinews', 'Press Releases')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/news-events/media-resources', 'News &amp; Events', 'nciglobal, ncienglish-all, ncinews', 'Media Resources')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/news-events/events', 'News &amp; Events', 'nciglobal, ncienglish-all, ncinews', 'Events')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/news-events/cancer-currents-blog', 'News &amp; Events', 'nciglobal, ncienglish-all, ncinews', 'Cancer Current Blog')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/news-events/events/conferences', 'News &amp; Events', 'nciglobal, ncienglish-all, ncinews', 'Conferences')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/about-nci', 'About NCI', 'nciglobal, ncienglish-all, nciabout', 'About NCI Landing Page')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/about-nci/overview', 'About NCI', 'nciglobal, ncienglish-all, nciabout', 'Overview')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/about-nci/budget', 'About NCI', 'nciglobal, ncienglish-all, nciabout', 'Budget')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/about-nci/leadership', 'About NCI', 'nciglobal, ncienglish-all, nciabout', 'Leadership')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/about-nci/careers', 'About NCI', 'nciglobal, ncienglish-all, nciabout', 'Careers')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/about-nci/organization', 'About NCI', 'nciglobal, ncienglish-all, nciabout', 'Organization')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/about-nci/visit', 'About NCI', 'nciglobal, ncienglish-all, nciabout', 'Visitor Information')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/about-nci/advisory-boards', 'About NCI', 'nciglobal, ncienglish-all, nciabout', 'Advisory Boards and Groups')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/publications', 'Publications', 'nciglobal, ncienglish-all', 'Publications Landing Page')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/publications/dictionaries/cancer-terms', 'Publications', 'nciglobal, ncienglish-all, ncincidictionary', 'Dictionary of Cancer Terms')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/publications/dictionaries/cancer-drug', 'Publications', 'nciglobal, ncienglish-all, ncidrugdictionary', 'NCI Drug Dictionary')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/publications/patient-education', 'Publications', 'nciglobal, ncienglish-all', 'Patient Education Publications')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/publications/pdq', 'Publications', 'nciglobal, ncienglish-all', 'PDQ Publications')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/publications/blogs-newsletters', 'Publications', 'nciglobal, ncienglish-all', 'Blogs and Newsletters')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/about-website', 'Global Pages', 'nciglobal, ncienglish-all', 'About Website')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/contact', 'Global Pages', 'nciglobal, ncienglish-all', 'Contact Pages')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/global', 'Global Pages', 'nciglobal, ncienglish-all', 'Global Landing Page')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/resources-for', 'Resources For', 'nciglobal, ncienglish-all', 'Resources For')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol', 'NCI Home - Spanish', 'nciglobal, ncispanish-all', 'NCI Home - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/cancer', 'About Cancer - Spanish', 'nciglobal, ncispanish-all, ncielcancer', 'About Cancer Landing Page - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/cancer/que-es', 'About Cancer - Spanish', 'nciglobal, ncispanish-all, ncielcancer', 'What is Cancer - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/cancer/tratamiento', 'About Cancer - Spanish', 'nciglobal, ncispanish-all, ncielcancer', 'Treatment - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/cancer/tratamiento/estudios-clinicos', 'About Cancer - Spanish', 'nciglobal, ncispanish-all, nciclinicaltrials', 'Clinical Trials - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/cancer/causas-prevencion', 'About Cancer - Spanish', 'nciglobal, ncispanish-all, ncielcancer', 'Causes &amp; Prevention - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/cancer/sobrellevar', 'About Cancer - Spanish', 'nciglobal, ncispanish-all, ncielcancer', 'Coping - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/cancer/deteccion', 'About Cancer - Spanish', 'nciglobal, ncispanish-all, ncielcancer', 'Screening - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/cancer/cancer-avanzado', 'About Cancer - Spanish', 'nciglobal, ncispanish-all, ncielcancer', 'Advanced Cancer - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/cancer/diagnostico-estadificacion', 'About Cancer - Spanish', 'nciglobal, ncispanish-all, ncielcancer', 'Diagnosis &amp; Staging - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/cancer/manejo-del-cancer', 'About Cancer - Spanish', 'nciglobal, ncispanish-all, ncielcancer', 'Managing Cancer Care - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/tipos', 'Cancer Types - Spanish', 'nciglobal, ncispanish-all, ncitiposdecancer', 'Cancer Types Landing Page - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/tipos/por-partes-cuerpo', 'Cancer Types - Spanish', 'nciglobal, ncispanish-all, ncitiposdecancer', 'Cancer Types (Other) - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/tipos/comunes', 'Cancer Types - Spanish', 'nciglobal, ncispanish-all, ncitiposdecancer', 'Cancer Types (Other) - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/tipos/infantil', 'Cancer Types - Spanish', 'nciglobal, ncispanish-all, ncitiposdecancer', 'Childhood Cancers - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/investigacion', 'Research - Spanish', 'nciglobal, ncispanish-all', 'Research Landing Page - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/investigacion/papel-del-nci', 'Research - Spanish', 'nciglobal, ncispanish-all', 'NCI Role - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/investigacion/progreso', 'Research - Spanish', 'nciglobal, ncispanish-all', 'Research Progess - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/subvenciones-capacitacion', 'Grants &amp; Training - Spanish', 'nciglobal, ncispanish-all', 'Grants &amp; Training - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/noticias', 'News &amp; Events - Spanish', 'nciglobal, ncispanish-all, ncinoticias', 'News &amp; Events Landing Page - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/noticias/comunicados-de-prensa', 'News &amp; Events - Spanish', 'nciglobal, ncispanish-all, ncinoticias', 'Press Releases - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/instituto', 'About NCI - Spanish', 'nciglobal, ncispanish-all, ncinuestroinstituto', 'About NCI (Other) - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/instituto/general', 'About NCI - Spanish', 'nciglobal, ncispanish-all, ncinuestroinstituto', 'Overview - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/instituto/director', 'About NCI - Spanish', 'nciglobal, ncispanish-all, ncinuestroinstituto', 'Leadership - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/publicaciones', 'Publications - Spanish', 'nciglobal, ncispanish-all', 'Publications Landing Page - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/publicaciones/educacion-para-pacientes', 'Publications - Spanish', 'nciglobal, ncispanish-all', 'Patient Education Publications - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/publicaciones/pdq', 'Publications - Spanish', 'nciglobal, ncispanish-all', 'PDQ Publications - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/buscar', 'Search - Spanish', 'nciglobal, ncispanish-all', 'Search - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/publicaciones/diccionario', 'Publications - Spanish', 'nciglobal, ncispanish-all', 'Dictionary of Cancer Terms - Spanish')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/contactenos', 'Global Pages - Spanish', 'nciglobal, ncispanish-all', 'Contact Page')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/contactenos/centro-de-contacto', 'Global Pages - Spanish', 'nciglobal, ncispanish-all', 'Contact Page')
insert into #t (url, channel, suite, [content-group]) values('www.cancer.gov/espanol/politicas', 'Global Pages - Spanish', 'nciglobal, ncispanish-all', 'Policies')


select 
 n.contentid as navonID,  f.CONTENTID as folderID
 , dbo.gaogetitemFolderPath(f.contentid , '') + '/'+  c1.title  as folderpath
 into #navonFolder 
from RXS_CT_NAVON n 
inner join contentstatus c on c.contentid = n.contentid and n.REVISIONID = c.CURRENTREVISION
inner join PSX_OBJECTRELATIONSHIP r on n.CONTENTid = r.DEPENDENT_ID
inner join psx_folder f on f.contentid = r.OWNER_ID
inner join contentstatus c1 on c1.contentid = f.CONTENTID
inner join RXCOMMUNITY m on m.COMMUNITYID = c.COMMUNITYID 
where m.NAME <> 'CDR_PublishPreview' and dbo.gaogetitemFolderPath(f.contentid , '') not like 'MobileCancerGov%'


select n.contentid as NavTreeID, dbo.gaogetitemFolderPath(n.contentid , '') as sitename
into #navTree
from RXS_CT_NAVTREE n 
inner join contentstatus c on c.contentid = n.contentid and n.REVISIONID = c.CURRENTREVISION
inner join PSX_OBJECTRELATIONSHIP r on n.CONTENTid = r.DEPENDENT_ID
inner join psx_folder f on f.contentid = r.OWNER_ID
inner join contentstatus c1 on c1.contentid = f.CONTENTID
inner join RXCOMMUNITY m on m.COMMUNITYID = c.COMMUNITYID 
where m.NAME <> 'CDR_PublishPreview' and dbo.gaogetitemFolderPath(n.contentid , '') not like 'MobileCancerGov%'



select * into #siteNameMap from
(
select 'cancergov' as sitename, 'www.cancer.gov' as url
union
select 'DCEG', 'DCEG.cancer.gov'
union
select 'TCGA', 'cancergenome.nih.gov'
union
select 'imaging', 'imaging.cancer.gov'
union
select 'Proteomics', 'Proteomics.cancer.gov'
)a

----NavTree
--------------------------------------

update w set w.CHANNEL = u.channel, w.REPORT_SUITE = u.Suite, w.CONTENT_GROUP = u.[content-group] 
 from #t u 
inner join #siteNameMap sm on sm.url = u.url 
inner join #navtree n  on n.sitename = sm.sitename 
inner join GENWEBANALYTICS_GENWEBANALYTICS w on w.CONTENTID = n.navtreeID

insert into GENWEBANALYTICS_GENWEBANALYTICS (contentid, REVISIONID , REPORT_SUITE , CHANNEL , CONTENT_GROUP )
select c.contentid , nv.REVISIONID , u.suite, u.channel, u.[content-group]
 from #t u 
inner join #siteNameMap sm on sm.url = u.url 
inner join #navtree n  on n.sitename = sm.sitename 
inner join contentstatus c on n.NavTreeID  = c.contentid 
inner join RXS_CT_NAVTREE  nv on nv.CONTENTID = c.contentid 
left outer join GENWEBANALYTICS_GENWEBANALYTICS w on w.CONTENTID = n.navtreeID
where w.contentid is null


update w set w.CHANNEL = u.channel, w.REPORT_SUITE = u.Suite, w.CONTENT_GROUP = u.[content-group] 
from #t u  
inner join #siteNameMap sm on  case when charindex('/', u.url) = 0 then u.url else  left(u.url, charindex('/', u.url)-1) END = sm.url
inner join #navonFolder n  on sm.sitename+ substring(u.url,charindex('/', u.url), 9999) = n.folderpath 
inner join GENWEBANALYTICS_GENWEBANALYTICS w on w.CONTENTID = n.navonID


insert into GENWEBANALYTICS_GENWEBANALYTICS (contentid, REVISIONID , REPORT_SUITE , CHANNEL , CONTENT_GROUP )
select c.contentid , nv.REVISIONID , u.suite, u.channel, u.[content-group]
from #t u  
inner join #siteNameMap sm on  case when charindex('/', u.url) = 0 then u.url else  left(u.url, charindex('/', u.url)-1) END = sm.url
inner join #navonFolder n  on sm.sitename+ substring(u.url,charindex('/', u.url), 9999) = n.folderpath 
inner join contentstatus c on n.navonID = c.contentid 
inner join RXS_CT_NAVON nv on nv.CONTENTID = c.contentid 
left outer join GENWEBANALYTICS_GENWEBANALYTICS w on w.CONTENTID = n.navonID
where w.CONTENTID is null



