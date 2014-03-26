USE [PercCancerGov]
GO

/****** Object:  View [dbo].[cgvPageSearch]    Script Date: 03/17/2014 19:34:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
drop view [cgvPageSearch]
go

create view [dbo].[cgvPageSearch]
as 

select 
p.contentid, Short_Description , short_title, long_title, meta_keywords, legacy_search_filter, Date_display_mode
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
, p.site
, imagesource
,alttext
,abbreviatedsource
, sort_date
, subscription_required
,m.Alt
,m.Caption 
,m.ArticleImageURL
, m.widefeatureURL
, m.LongDescURL
,m.ThumbnailURL
,m.EnlargeURL
,m.PanoramicImageURL
from dbo.cgvPageMetaData p left outer join gloImageMetaData m on p.imageid = m.contentid
where p.blogbody is null

GO