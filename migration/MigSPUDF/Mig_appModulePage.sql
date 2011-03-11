drop procedure dbo.Mig_appModulePage
go
create procedure dbo.Mig_appModulePage
as
select 
long_title,
snippet_control_path,
config,
short_title,
long_description,
short_description,
meta_description,
meta_keywords,
0 as showpagetitle,
print_available,
email_available,
share_available,
template,
pretty_url_name,
[pretty url] as prettyurl,
community
from appmodule
GO

update appmodule
set template = 'no_left_nav'
--------------
