use percussion

;with folders as (
					  select null as ParentID, f.ContentID as ID, cs.title as FolderName, 
					convert(varchar(512),'') as Path
					  from PSX_folder f join contentstatus cs on f.contentid = cs.contentid
					  where cs.contentid = 305
					  UNION ALL
					  select r.owner_ID as ParentID, f.contentid as ID, cs.title as FolderName, 
					convert(varchar(512),folders.Path + '/' + cs.title) as Path
					  from PSX_folder f inner JOIN PSX_ObjectRelationship r  ON r.dependent_id = f.contentid
					  inner JOIN folders ON folders.ID = r.owner_id
					  inner join contentstatus cs on f.contentid = cs.contentid
				)
select * into #folder from folders
	
select  
c.contentid , 
'www.cancer.gov' + f.path + isnull('/'+ dbo.percReport_getPretty_url_name(c.contentid), '') as desktopurl
, c.TITLE 
, contenttypename
, path as folder
, statename 
into #d
from dbo.contentstatus c 
inner join dbo.psx_objectrelationship ff on c.contentid = ff.dependent_id and config_id = 3
inner join #folder f on f.id = ff.owner_id
inner join contenttypes t on t.contenttypeid = c.contenttypeid
inner join STATES  s on s.STATEID = c.CONTENTSTATEID  and s.WORKFLOWAPPID = c.WORKFLOWAPPID
where 
contenttypename in 
(
select distinct c.CONTENTTYPENAME --, t.name 
from PSX_CONTENTTYPE_TEMPLATE ct inner join psx_template t on t.TEMPLATE_ID = ct.TEMPLATE_ID 
inner join contenttypes c on c.contenttypeid = ct.CONTENTTYPEID
where t.Assembler = 'Java/global/percussion/assembly/velocityAssembler' AND t.OutputFormat = 1 
and CONTENTTYPENAME in ('nciGeneral', 'nciLandingpage')
) 

go 
drop table #folder 


;with folders as (
					  select null as ParentID, f.ContentID as ID, cs.title as FolderName, 
					convert(varchar(512),'') as Path
					  from PSX_folder f join contentstatus cs on f.contentid = cs.contentid
					  where cs.contentid = 172511
					  UNION ALL
					  select r.owner_ID as ParentID, f.contentid as ID, cs.title as FolderName, 
					convert(varchar(512),folders.Path + '/' + cs.title) as Path
					  from PSX_folder f inner JOIN PSX_ObjectRelationship r  ON r.dependent_id = f.contentid
					  inner JOIN folders ON folders.ID = r.owner_id
					  inner join contentstatus cs on f.contentid = cs.contentid
				)
				
			  select * into #folder from folders
	
	
	
	
select  
c.contentid , 
'm.cancer.gov' + f.path + isnull('/'+ dbo.percReport_getPretty_url_name(c.contentid), '') as mobileurl
, c.TITLE 
, contenttypename
, path as folder
, statename 
into #m
from dbo.contentstatus c 
inner join dbo.psx_objectrelationship ff on c.contentid = ff.dependent_id and config_id = 3
inner join #folder f on f.id = ff.owner_id
inner join contenttypes t on t.contenttypeid = c.contenttypeid
inner join STATES  s on s.STATEID = c.CONTENTSTATEID  and s.WORKFLOWAPPID = c.WORKFLOWAPPID
where 
contenttypename in 
(
select distinct c.CONTENTTYPENAME --, t.name 
from PSX_CONTENTTYPE_TEMPLATE ct inner join psx_template t on t.TEMPLATE_ID = ct.TEMPLATE_ID 
inner join contenttypes c on c.contenttypeid = ct.CONTENTTYPEID
where t.Assembler = 'Java/global/percussion/assembly/velocityAssembler' AND t.OutputFormat = 1 
and CONTENTTYPENAME in ('nciGeneral', 'nciLandingpage')
) 


select isnull(d.CONTENTID, m.contentid) as contentid
, isnull(d.TITLE, m.title) as title
, isnull(d.CONTENTTYPENAME, m.contenttypename) as contenttypename
, isnull(d.STATENAME, m.statename)  as state
, d.desktopurl , d.folder 
, m.mobileurl , m.folder as mobilefolder 
into #s
from #d d full outer join #m m on d.CONTENTID = m.CONTENTID
order by d.desktopurl 


----EXCEPTION
create table #exclude (contentid int)
truncate table #exclude
insert into #exclude
select contentid from CONTENTSTATUS where CONTENTID in 
(57469,
16362,
176775,
280777,
177549,
13367,
14423,
13963,
15273,
76315,
76319,
76318,
76316,
13339)


create table #generaltoArticle(contentid int)
insert into #generaltoArticle
select contentid from contentstatus where contentid in 
(922408,
922400,
922401,
922411,
922404,
922405,
923421,
916009,
916031,
916034,
916033,
916020,
916030,
916037,
916017,
109064,
13982,
915356,
916035,
922595,
915357,
915358,
922598,
915359,
695232,
15113,
915360,
869871,
882531,
882601,
882604,
882607,
882610,
882624,
882631,
882634,
882446,
915350,
882656,
882657,
882658,
882591,
882520,
882505,
882439,
882397,
882442,
882436,
882433,
882415,
882379,
882350,
882333,
882315,
915363,
915365,
858316,
858342,
859575,
859567,
858277,
859630,
859589,
859593,
859632,
866185,
859988,
859833,
859813,
860657,
858130,
859577,
859781,
859665,
859637,
859757,
170976,
903689,
172407,
906094,
903866,
903603,
903598,
903599,
903600,
903604,
819877,
819878,
819946,
819945,
905020,
63858,
857634,
420531,
420524,
420528,
420515,
420512,
802442,
420505,
445936,
857613,
777775,
396117,
396060,
396064,
396077,
396065,
419029,
396061,
420502,
684821,
171104,
898468,
901854,
901860,
903708,
903722,
903736,
914948,
903737,
903745,
903748,
903755,
901824,
902108,
903713,
903727,
902281,
902109,
903717,
919144,
903729,
912839,
912902,
915530,
912885,
915540,
912891,
814466,
13704,
923366,
804561,
804564,
804565,
804566,
804563,
804586,
804567,
804750,
804751,
804738,
804698,
804716,
804689,
804715,
804757,
804752,
804753,
804755,
809328,
804933,
804754,
804756,
802753,
13209,
860215,
858333,
858327,
858328,
858331,
858334,
858332,
858326,
860212,
858325,
858323,
858324,
858338,
858341,
858335,
858337,
858340,
858336,
858339,
16279,
14304,
867905,
768980,
768977,
748303,
762659,
762657,
762633,
762660,
762655,
762658,
762661,
762665,
762664,
762663,
870061,
828593,
828648,
828697,
828658,
828659,
828660,
849033,
833184,
833185,
833186,
833187,
848368,
849846,
849776,
849777,
849822,
849014,
869607,
833197,
833198,
833272,
833273,
697265,
698571,
695704,
843921,
697262,
15309,
587661,
916855,
112133,
800098,
804860,
916804,
915364,
915367,
915048,
915049,
914834,
915047,
915046,
914835,
915051,
915261,
915263,
16226,
65964,
16143,
65887,
65973,
65884,
68514,
68595,
68601,
65990,
68353,
68379,
68382,
68408,
68415,
68483,
550782,
65947,
65958,
15305,
151032,
151034,
151035,
151033,
765018,
570077,
792791,
570076,
151036,
151037,
151038,
605836,
151039,
151040,
151041,
151042,
151058,
495557,
14798,
15059,
915637,
915642,
917217,
770089,
814247,
789639,
829631,
821432,
915643,
915644,
915651,
915654,
914512,
915663,
915676,
915680,
839138,
267291,
13184,
916690,
14365,
14545,
15600,
12998,
15821,
13320,
13432,
13440,
15069,
12997,
14078,
12872,
15686,
13021,
15747,
13974,
59028,
15349,
13829,
13760,
15172,
14572,
13314,
13022,
13751,
13627,
14028,
13644,
13925,
15621,
15104,
15685,
15395,
15395,
15468,
13186,
15817,
15010,
12989,
13473,
13645,
13294,
15491,
15595,
14553,
15839,
13106,
14835,
15355,
12925,
14375,
14908,
14352,
13943,
13372,
13306,
14244,
15718,
13392,
13516,
13386,
14215,
801796,
799372,
816965,
816967,
816969,
817097,
817098,
817099,
817102,
799332,
916787,
678485,
684837,
885576,
748346,
909129,
898807,
827181,
730874,
848054,
728762,
679249,
637652,
762580,
679331,
866195,
679052,
678040,
754654,
759773,
929956,
488505,
479140,
481162,
484116,
483058,
487763,
457193,
483372,
484117,
487344,
487752,
487805,
487870,
488040,
488059,
488911,
488730,
488731,
488732,
488733,
488734,
488735,
488736,
488737,
488738,
57473,
57472,
57471,
57470,
57474,
633818,
538214,
546269,
546272,
546264,
546210,
546085,
112300,
120765,
120774,
120775,
120776,
120777,
120778,
120779,
120766,
120767,
120768,
120769,
120770,
120771,
120772,
120773,
120780,
120781,
120782,
545378,
13782,
14143,
13720,
13193,
849987,
14587,
814107,
15181,
819948,
884327,
73729,
109372,
109373,
102654,
82014,
78747,
14658,
15165,
15175,
13357,
327274,
13362,
298554,
15019,
821970,
824935,
821979,
822289,
850495,
819882,
826390,
824933,
819941,
822287,
823316,
819883,
822294,
819943,
822290,
819939,
821975,
821964,
819785,
822281,
824909,
826389,
819879,
821962,
819784,
826233,
823710,
824934,
821967,
819881,
824184,
819944,
822305,
823928,
822293,
821977,
821972,
819880,
822283,
821969,
826381,
826388,
819947,
819940,
822302,
822301,
821976,
822285,
675725,
571449,
545310,
702842,
759574,
101531,
216653,
15769,
78748,
14398,
13778,
76494,
84005,
84006,
78673,
697302,
697303,
820126,
512288,
512241,
802443,
512244,
512291,
512107,
512206,
512161,
512203,
512237,
512234,
512200,
512339,
512275,
857655,
512279,
512280,
512285,
725774,
725777,
725751,
725754,
725753,
725775,
725776,
725792,
725781,
725789,
725780,
725783,
725784,
725785,
725786,
725787,
725788,
725790,
725782,
725779,
725791,
725778,
725752,
725793,
725750,
840870,
826659,
838037,
840734,
840738,
826664,
840848,
838101,
840735,
840807,
840731,
838597,
840772,
838078,
840771,
840869,
838079,
838080,
840804,
840806,
826663,
840732,
840730,
826660,
838598,
840727,
840775,
826661,
826656,
840729,
826658,
326530,
326525,
333439,
622403,
771748,
583446,
326544,
622407,
331376,
326565,
326541,
326568,
326536,
326305,
585070,
13003,
74425,
14467,
909708,
909794,
909796,
909834,
909802,
909711,
910917,
910929,
910931,
910930,
910928,
911086,
911087,
911091,
911088,
911089,
911090,
909507,
909843,
910942,
910945,
910944,
910943,
910946,
586771,
819084,
505574,
112142,
777531,
230011,
177547,
177548,
177546,
429220,
917551,
929833,
929839,
917535,
917549,
929829,
929830,
929840,
917558,
929827,
915564,
917550,
916571,
917712,
916602,
916635,
916796,
916036,
917552,
916032,
916021,
916019,
917641,
916015,
917563,
916011,
917484,
915969,
917478,
915879,
915941,
917467,
917457,
917455,
917448,
915869,
917433,
915751,
912325,
912690,
912888,
870528,
911657,
14890,
860491,
63856,
898412,
505608,
412019,
512109,
858227,
859583,
859801,
859634)




------------------------------------------------------


------------------------
------------------------
-----GENERAL



if OBJECT_ID('tempdb.dbo.#gaoTgeneralToTopic') is not null
	drop table #gaoTgeneralToTopic
GO
select s.*, 'generalToTopic' as NewType_rule
into #gaoTgeneralToTopic
from #s s 
where contentid in 
(883453,
13054,
12954,
14034,
15132,
63867,
14930,
804515,
804516,
804517,
747173,
833173,
847972,
833192,
783956,
810260,
915271,
914801,
914833,
15853,
63861,
905791,
14257,
799546,
816922,
799373,
14689,
13795,
794087,
13792,
105818,
14879,
916945,
912305,
16169)


if OBJECT_ID('tempdb.dbo.#gaoTgeneralToLanding') is not null
	drop table #gaoTgeneralToLanding
GO
select s.* , 'generalToLanding' as NewType_rule
into #gaoTgeneralToLanding
from #s s 
where s.contentid = 15288



if OBJECT_ID('tempdb.dbo.#gaoTgeneraltoarticle') is not null
	drop table #gaoTgeneraltoarticle
go
select s.*, 'generalToArticle' as NewType_rule
into #gaoTGeneralToArticle
from #s s 
where contentid not in 
(
select contentid 
from CONTENTSTATUS c 
inner join PSX_OBJECTRELATIONSHIP r on r.OWNER_ID = c.CONTENTID and r.OWNER_REVISION = c.CURRENTREVISION
inner join rxslottype s on s.SLOTID = r.SLOT_ID
where s.SLOTNAME  in ('cgvBody')
)
and contentid in (select contentid from #generaltoArticle)


------------Landing
if OBJECT_ID('tempdb.dbo.#gaoTLandingToGeneral') is not null
	drop table #gaoTLandingToGeneral
GO
select s.*, 'landingToGeneral' as NewType_rule
into #gaoTLandingToGeneral
from #s s 
where contentid in (176775,
280777,
177549)


if OBJECT_ID('tempdb.dbo.#gaoTLandingToArticle') is not null
	drop table #gaoTLandingToArticle
GO
select s.* , 'landingToArticle' as NewType_rule
into #gaoTLandingToArticle
from #s s 
where s.contentid in( 57469,16362)


if OBJECT_ID('tempdb.dbo.#gaoTLandingToTopic') is not null
	drop table #gaoTLandingToTopic
GO
select s.*, 'landingToTopic' as NewType_rule
into #gaoTLandingToTopic
from #s s 
where contenttypename = 'ncilandingpage' and contentid not in  (select contentid from #exclude)

---------------End of Landing








----------------------------------------------
------

----------

select 'exec dbo.gaolandingtotopic ' + convert(varchar(20),contentid ) 
from #gaoTLandingToTopic 

select 'exec dbo.gaolandingtogeneral ' + convert(varchar(20),contentid ) 
from #gaoTLandingToGeneral 

select 'exec dbo.gaogeneralToTopic ' + convert(varchar(20),contentid ) 
from #gaoTgeneralToTopic

select 'exec dbo.gaogeneraltoarticle ' + convert(varchar(20),contentid ) 
from #gaoTGeneralToArticle

select 'exec dbo.gaogeneraltolanding ' + convert(varchar(20),contentid ) 
from #gaoTgeneralToLanding

select 'exec dbo.gaoLandingtoArticle ' + convert(varchar(20),contentid ) 
from #gaoTLandingToArticle


	; with rules(contentid,	NewType_rule)
	AS
	(select contentid, NewType_rule from #gaoTGeneralToArticle
	union
	select contentid, NewType_rule from #gaoTgeneralToTopic
	union
	select contentid, NewType_rule from #gaoTgeneralToLanding
	union
	select contentid, NewType_rule from #gaoTLandingToGeneral
	union 
	select contentid, NewType_rule from #gaoTLandingToArticle
	union
	select contentid, NewType_rule from #gaoTLandingToTopic
	) 

select s.*, isnull(r.NewType_rule , 'noConvert') as NewType_rule
	from #s s left outer join rules r on s.contentid = r.contentid 
	where s.contentid not in (select contentid from #generaltoarticle union all select contentid from #exclude)
	union all
	select s.*, isnull(r.NewType_rule , 'noConvert_hasBODY')
	from #s s left outer join rules r on s.contentid = r.contentid 
	where s.contentid in (select contentid from #generaltoarticle)
	union all
	select s.*, isnull(r.NewType_rule , 'noConvert_exception')
	from #s s left outer join rules r on s.contentid = r.contentid 
	where s.contentid in (select contentid from #exclude)
order by  contenttypename , NewType_rule



	
	
	
	


