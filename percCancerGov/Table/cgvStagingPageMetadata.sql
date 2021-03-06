SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cgvStagingPageMetadata]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[cgvStagingPageMetadata](
	[CONTENTID] [int] NOT NULL,
	[LONG_TITLE] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SHORT_TITLE] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LONG_DESCRIPTION] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SHORT_DESCRIPTION] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[META_KEYWORDS] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PRETTYURL] [nvarchar](300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DATE_FIRST_PUBLISHED] [datetime] NULL,
	[DATE_LAST_MODIFIED] [datetime] NULL,
	[DATE_LAST_REVIEWED] [datetime] NULL,
	[DATE_NEXT_REVIEW] [datetime] NULL,
	[DATE_DISPLAY_MODE] [int] NULL,
	[LEGACY_SEARCH_FILTER] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LANGUAGE] [nchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VIDEOURL] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AUDIOURL] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IMAGEURL] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[News_QandA_URL] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OTHERLANGUAGECONTENTID] [int] NULL,
	imagesource varchar(300),
	alttext varchar(512),
	abbreviatedsource varchar(50),
	sort_date datetime,
	subscription_required bit,
	site nvarchar(200) NOT NULL constraint DF_cgvStagingPageMetadata_site default 'unknown',
	taxonomyTag nvarchar(1000),
	allowComments bit ,
PRIMARY KEY CLUSTERED 
(
	[CONTENTID] ASC,
	site
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
use percCancergov


alter table  dbo.cgvstagingpagemetadata add IMAGEID int
GO



alter table  dbo.cgvstagingpagemetadata add blogBody nvarchar(max)

GO



alter table  dbo.cgvstagingpagemetadata add author nvarchar(100)
GO



alter table  dbo.cgvstagingpagemetadata add contenttype nvarchar(100)
GO
