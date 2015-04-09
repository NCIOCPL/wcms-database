USE [PercCancerGov]
GO

drop view [dbo].[cgvPageSearch]
go


/****** Object:  View [dbo].[cgvPageSearch]    Script Date: 02/06/2015 16:53:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

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
, NULL as blogparagraph
,p.author
,p.contenttype
, p.item_size
, p.item_type 
from dbo.cgvPageMetaData p left outer join gloImageMetaData m on p.IMAGEID  = m.contentid



GO


