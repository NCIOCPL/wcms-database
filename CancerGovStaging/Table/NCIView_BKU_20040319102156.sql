SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[NCIView_BKU_20040319102156]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[NCIView_BKU_20040319102156](
	[NCIViewID] [uniqueidentifier] NOT NULL,
	[NCITemplateID] [uniqueidentifier] NULL,
	[NCISectionID] [uniqueidentifier] NULL,
	[GroupID] [int] NULL,
	[Title] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ShortTitle] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Description] [varchar](1500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[HTMLAddendum] [varchar](1500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[URL] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[URLArguments] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OldURL] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MetaTitle] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MetaDescription] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MetaKeyword] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateDate] [datetime] NULL,
	[ReleaseDate] [datetime] NULL,
	[ExpirationDate] [datetime] NULL,
	[Version] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Status] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsOnProduction] [bit] NULL,
	[IsMultiSourced] [int] NOT NULL,
	[IsLinkExternal] [bit] NULL,
	[SpiderDepth] [int] NULL,
	[UpdateDate] [datetime] NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PostedDate] [datetime] NOT NULL,
	[DisplayDateMode] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
END
GO
