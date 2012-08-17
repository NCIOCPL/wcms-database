USE [percCancergov]
GO
alter table dbo.cgvPageMetadata add sort_date datetime
alter table dbo.cgvStagingPageMetadata add sort_date datetime
GO


/****** Object:  View [dbo].[cgvPageSearch]    Script Date: 06/07/2012 13:59:13 ******/
drop view [dbo].[cgvPageSearch]
go

create view [dbo].[cgvPageSearch]
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
, subheader
, site
, imagesource
,alttext
,abbreviatedsource
, sort_date
from dbo.cgvPageMetaData p

GO

USE [percCancergov]
GO
/****** Object:  View [dbo].[cgvStagingPageSearch]    Script Date: 06/07/2012 14:00:38 ******/
drop view [dbo].[cgvStagingPageSearch]
go

create view [dbo].[cgvStagingPageSearch]
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
, subheader
, site
,imagesource
,alttext
,abbreviatedsource
, sort_date
from dbo.cgvStagingPageMetaData p





