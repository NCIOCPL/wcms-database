use PercCancerGov
GO

if OBJECT_ID('gloStagingImageMetaData') is not null
	drop table dbo.gloStagingImageMetaData 

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
create table dbo.gloStagingImageMetaData 
(contentid int not null
, Alt nvarchar(512)
, Caption nvarchar(max)
, LongDescURL nvarchar(400)
, ArticleImageURL nvarchar(400)
,EnlargeURL  nvarchar(400)
, ThumbnailURL nvarchar(400)
, WideFeatureURL nvarchar(400)
, PanoramicImageURL nvarchar(400)
,[site] [nvarchar](400) NOT NULL
)
GO
alter table gloStagingImageMetadata add constraint PK_gloStagingImageMetaData Primary key CLUSTERED (contentid, site)
GO