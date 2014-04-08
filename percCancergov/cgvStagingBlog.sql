use PercCancerGov
GO
if OBJECT_ID('cgvStagingBlog') is not null
	drop view dbo.cgvStagingBlog
GO
Create view dbo.cgvStagingBlog
as
select 
p.contentid, Short_Description , short_title, long_title, meta_keywords, legacy_search_filter, Date_display_mode
,Long_Description
, date_last_reviewed
,date_last_modified
, Date_first_published
, prettyurl, language, videourl, audiourl, imageurl, news_qanda_url
,(select top 1 prettyurl from dbo.cgvstagingpagemetadata t where t.contentid = p. otherlanguagecontentid) as otherlanguageURL
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
,blogbody as blogparagraph
,author
,p.contenttype
from dbo.cgvStagingPageMetaData p left outer join dbo.glostagingImageMetaData m on p.imageid = m.contentid
where p.LEGACY_SEARCH_FILTER  like 'Blog Series-%'