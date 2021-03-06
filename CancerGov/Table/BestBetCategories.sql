SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[BestBetCategories]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BestBetCategories](
	[CategoryID] [uniqueidentifier] NOT NULL DEFAULT (newid()),
	[CatName] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CatProfile] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ListID] [uniqueidentifier] NULL,
	[Weight] [int] NULL DEFAULT (50),
	[UpdateDate] [datetime] NULL DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL DEFAULT (user_name()),
	[Status] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL DEFAULT ('Edit'),
	[IsOnProduction] [bit] NULL,
	[ChangeComments] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsSpanish] [bit] NOT NULL DEFAULT (0),
	[IsExactMatch] [bit] NOT NULL CONSTRAINT [DF_BestBetCategories_IsExactMatch]  DEFAULT (0),
PRIMARY KEY CLUSTERED 
(
	[CategoryID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
