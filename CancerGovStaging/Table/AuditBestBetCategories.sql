SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[AuditBestBetCategories]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[AuditBestBetCategories](
	[AuditActionType] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CategoryID] [uniqueidentifier] NULL,
	[CatName] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CatProfile] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ListID] [uniqueidentifier] NULL,
	[Weight] [int] NULL,
	[UpdateDate] [datetime] NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Status] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsOnProduction] [bit] NULL,
	[AuditActionDate] [datetime] NULL DEFAULT (getdate()),
	[AuditActionUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL DEFAULT (user_name()),
	[ChangeComments] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsSpanish] [bit] NULL,
	[IsExactMatch] [bit]  NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
