drop procedure Mig_AppWidgetShellPage
go
create procedure Mig_AppWidgetShellPage
as
select NCIViewid as viewid,
long_title,
short_title,
long_description,
short_description,
meta_description,
meta_keywords,
0 as showpagetitle,
print_available,
email_available,
share_available,
[content type],
pretty_url_name,
[pretty url] as prettyurl,
community,
language as sys_lang
from ncigeneral
GO


drop procedure Mig_AppWidget
go
create procedure Mig_AppWidget
as
select 
objectid,
long_title,
snippet_control_path,
config
from appwidget
where snippet_control_path is not null
GO


drop procedure Mig_AddAppWidget

GO
create procedure Mig_AddAppWidget
as
select w.nciviewid as viewid , [content type] as [page content type], 
w.objectid,
 'nciAppWidget' as [content type],
'cgvBody' as slot , 'cgvSnAppWidget' as template
from appwidget w inner join ncigeneral g on w.nciviewid = g.nciviewid
union all
select w.nciviewid as viewid , 'nciGeneral' as [page content type], 
w.objectid,
 'nciAppWidget' as [content type],
'cgvBody' as slot , 'cgvSnAppWidget' as template
from appwidget w 
where nciviewid = '07312D4F-EFC4-4F40-8451-AFBEA0483E6D'
