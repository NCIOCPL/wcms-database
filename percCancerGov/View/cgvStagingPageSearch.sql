IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[cgvStagingPageSearch]'))
DROP VIEW [dbo].[cgvStagingPageSearch]
GO
create view dbo.cgvStagingPageSearch
as 

select 
contentid, Short_Description , short_title, long_title, meta_keywords, legacy_search_filter, Date_display_mode
,Long_Description
, date_last_reviewed
,date_last_modified
, Date_first_published
, prettyurl, language, videourl, audiourl, imageurl, news_qanda_url
,(select top 1 prettyurl from dbo.cgvpagemetadata t where t.contentid = p. otherlanguagecontentid) as otherlanguageURL
, case Date_Display_Mode   
 when '1' then Date_first_published
 when '5' then Date_first_published
 else date_last_modified
end as 'Date'

from dbo.cgvStagingPageMetaData p


GO
