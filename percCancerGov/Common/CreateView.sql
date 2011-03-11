if object_id('cgvPageSearch') is not NULL
	drop view dbo.cgvPageSearch
go

create view dbo.cgvPageSearch
as 
select 
contentid, Short_Description , short_title, long_title, meta_keywords, legacy_search_filter, Date_display_mode
,Long_Description
,date_last_modified
, Date_first_published
, prettyurl, language, videourl, audiourl, imageurl, news_qanda_url
, case Date_Display_Mode   
 when '1' then Date_first_published
 when '5' then Date_first_published
 else date_last_modified
end as 'Date'
from dbo.cgvPageMetaData 

GO
if object_id('cgvStagingPageSearch') is not NULL
	drop view dbo.cgvStagingPageSearch
go
create view dbo.cgvStagingPageSearch
as 
select 
contentid, Short_Description , short_title, long_title, meta_keywords, legacy_search_filter, Date_display_mode
,Long_Description
,date_last_modified
, Date_first_published
, prettyurl, language, videourl, audiourl, imageurl, news_qanda_url
, case Date_Display_Mode   
 when '1' then Date_first_published
 when '5' then Date_first_published
 else date_last_modified
end as 'Date'
from dbo.cgvStagingPageMetaData

GO

-----
----


--drop view dbo.SearchTest
--go
--create view dbo.SearchTest
--as 
--select 
--contentid, Short_Description , short_title, long_title, meta_keywords, legacy_search_filter, Date_display_mode
--,Long_Description
--,date_last_modified
--, Date_first_published
--, prettyurl, language, videourl, audiourl, imageurl, news_qanda_url
--, case Date_Display_Mode   
-- when '1' then Date_first_published
-- when '5' then Date_first_published
-- else date_last_modified
--end as 'Date'
--from dbo.searchSPtest
--
--GO
--
--drop view dbo.stagingsearchtest
--go
--create view dbo.stagingSearchTest
--as 
--select 
--contentid, Short_Description , short_title, long_title, meta_keywords, legacy_search_filter, Date_display_mode
--,Long_Description
--,date_last_modified
--, Date_first_published
--, prettyurl, language, videourl, audiourl, imageurl, news_qanda_url
--, case Date_Display_Mode   
-- when '1' then Date_first_published
-- when '5' then Date_first_published
-- else date_last_modified
--end as 'Date'
--from dbo.StagingSearchSPtest
--
--GO
