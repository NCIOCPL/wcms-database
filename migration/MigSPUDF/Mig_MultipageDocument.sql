
-- need to deal with backtotop and showpagetitle
drop function dbo.Mig_MultipageDocument
go
create function dbo.Mig_MultipageDocument (@nciviewid uniqueidentifier)
returns @r table 
(sys_lang varchar(80),
objectid uniqueidentifier, 
slot varchar(150), 
[Snippet Content Type] varchar(250),
[Snippet Template] varchar(250)
, long_title  varchar(255), 
short_title varchar(64), 
long_description varchar(2500), 
bodyfield varchar(max), 
table_of_contents varchar(max)
, priority int
,  showpagetitle bit
, backtotop bit
)
as
BEGIN
	
		insert into @r
			 select 
 isnull((select case when propertyvalue = 'YES' then 'es-us' when propertyvalue is null then 'en-us' else 'en-us' END from viewproperty vp where vp.nciviewid = m.nciviewid and propertyname = 'isSpanishContent'),  'en-us')  as sys_lang,
vo.objectid,slot,[Snippet Content Type],[Snippet Template], 
			d.title, d.shortTitle, description,  isnull(data,''), 
				case when [page content type] = 'cgvBooklet' then TOC ELSE NULL END, priority,
				dbo.mig_getshowpagetitle(m.nciviewid, d.documentid),
				dbo.mig_getbacktotop(m.nciviewid, d.documentid)
 
				from viewobjects vo inner join document d on d.documentid = vo.objectid
				inner join migmap m on m.nciviewid = vo.nciviewid and m.objectid = vo.objectid
				where vo.nciviewid = @nciviewid  	and 
					m.slot <> 'NA'
					and [page content type] in ('cgvBooklet', 'cgvCancerBulletin', 'cgvPowerPoint')
						
		order by priority			
	return
END
GO





