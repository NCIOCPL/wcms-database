drop procedure dbo.Mig_pageoptionbox
go

create procedure dbo.Mig_pageoptionbox
as
select 
'Page Options' long_title, 
'EDE35B9D-D1C0-4D5F-9E27-90F45613F827' as objectid,
[Content_version_key:] as content_version_key,
[Css_class:] as css_class,
[Link_text:] as link_text,
[Web_analytics_function:] as web_analytics_function,
[Option_type:] as option_type 
from pobenglish
union all
select 
'Opciones' long_title, 
'0A1ED33B-7F61-434F-8B7B-7CA76119277B' as objectid,
[Content_version_key:] as content_version_key,
[Css_class:] as css_class,
[Link_text:] as link_text,
[Web_analytics_function:] as web_analytics_function,
[Option_type:] as option_type 
from pobspanish
go