use PercCancerGov
GO
if OBJECT_ID('gloImageMetaData') is not null
	drop table dbo.gloImageMetaData 
go

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
create table dbo.gloImageMetaData 
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
alter table gloImageMetadata add constraint PK_gloImageMetaData Primary key CLUSTERED (contentid, site)

GO
