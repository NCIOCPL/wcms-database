create table gaoLandingConvert
(contentid int, url varchar(500), originaltype varchar(100))
go
insert dbo.gaolandingconvert(contentid,url,originaltype) values (15606,'/cancertopics/factsheet/Risk',null)
insert dbo.gaolandingconvert(contentid,url,originaltype) values (15063,'/cancertopics/factsheet/Sites-Types',null)
insert dbo.gaolandingconvert(contentid,url,originaltype) values (12955,'/cancertopics/factsheet/prevention',null)
insert dbo.gaolandingconvert(contentid,url,originaltype) values (14503,'/cancertopics/factsheet/detection',null)
insert dbo.gaolandingconvert(contentid,url,originaltype) values (13428,'/cancertopics/factsheet/Therapy',null)
insert dbo.gaolandingconvert(contentid,url,originaltype) values (13741,'/cancertopics/factsheet/Support',null)
insert dbo.gaolandingconvert(contentid,url,originaltype) values (13881,'/cancertopics/factsheet/Tobacco',null)
insert dbo.gaolandingconvert(contentid,url,originaltype) values (13747,'/cancertopics/factsheet/Information',null)
insert dbo.gaolandingconvert(contentid,url,originaltype) values (14369,'/cancertopics/factsheet/NCI',null)
insert dbo.gaolandingconvert(contentid,url,originaltype) values (13067,'/cancertopics/factsheet/disparities',null)
insert dbo.gaolandingconvert(contentid,url,originaltype) values (150999,'/espanol/recursos/hojas-informativas/tipos',null)
insert dbo.gaolandingconvert(contentid,url,originaltype) values (151001,'/espanol/recursos/hojas-informativas/riesgo-causas',null)
insert dbo.gaolandingconvert(contentid,url,originaltype) values (151003,'/espanol/recursos/hojas-informativas/prevencion',null)
insert dbo.gaolandingconvert(contentid,url,originaltype) values (151004,'/espanol/recursos/hojas-informativas/deteccion-diagnostico',null)
insert dbo.gaolandingconvert(contentid,url,originaltype) values (151006,'/espanol/recursos/hojas-informativas/tratamiento',null)
insert dbo.gaolandingconvert(contentid,url,originaltype) values (106628,'/espanol/recursos/hojas-informativas/estudios-clinicos',null)
insert dbo.gaolandingconvert(contentid,url,originaltype) values (151007,'/espanol/recursos/hojas-informativas/apoyo-recursos',null)
insert dbo.gaolandingconvert(contentid,url,originaltype) values (151005,'/espanol/recursos/hojas-informativas/instituto',null)
insert dbo.gaolandingconvert(contentid,url,originaltype) values (16391,'/diccionario',null)
insert dbo.gaolandingconvert(contentid,url,originaltype) values (16385,'/dictionary',null)


--------------------------------------
INSERT INTO CT_NCILANDINGPAGE
(CONTENTID, REVISIONID, TYPE, LANDING_PAGE_TYPE, CGV_TEMPLATE, CGV_M_TEMPLATE)
SELECT CONTENTID, REVISIONID, 'nciLandingPage' as TYPE
, 'two_columns' as LANDING_PAGE_TYPE
, 'general_lang' as CGV_TEMPLATE
, 'cgvMPgLandingPageLvl3' as CGV_M_TEMPLATE
FROM CT_CGVFACTSHEET
WHERE CONTENTID in
(select contentid from gaolandingconvert)
union
SELECT CONTENTID, REVISIONID, 'nciLandingPage' as TYPE, 
'two_columns' as LANDING_PAGE_TYPE, 'general_lang' as CGV_TEMPLATE, 
'cgvMPgLandingPageLvl3' as CGV_M_TEMPLATE
FROM CT_CGVSINGLEPAGECONTENT
WHERE CONTENTID in
(select contentid from gaolandingconvert)

UPDATE ContentStatus
SET CONTENTTYPEID = 473
WHERE CONTENTID in
(select contentid from gaolandingconvert)


delete from CT_CGVFACTSHEET
WHERE CONTENTID in
(select contentid from gaolandingconvert)

delete from CT_CGVSINGLEPAGECONTENT
WHERE CONTENTID in
(select contentid from gaolandingconvert)
------------------------------------------------