SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[AuditNCIView]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[AuditNCIView](
	[AuditActionType] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[NCIViewID] [uniqueidentifier] NOT NULL,
	[NCITemplateID] [uniqueidentifier] NULL,
	[NCISectionID] [uniqueidentifier] NULL,
	[GroupID] [int] NULL,
	[Title] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ShortTitle] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Description] [varchar](1500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[URL] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[URLArguments] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
	[PostedDate] [datetime] NULL,
	[DisplayDateMode] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AuditActionDate] [datetime] NOT NULL DEFAULT (getdate()),
	[AuditActionUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL DEFAULT (user_name()),
	[ReviewedDate] [datetime] NULL,
	[ChangeComments] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
END
GO
GRANT SELECT ON [dbo].[AuditNCIView] TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([AuditActionType]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([NCIViewID]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([NCITemplateID]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([NCISectionID]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([GroupID]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([Title]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([ShortTitle]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([Description]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([URL]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([URLArguments]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([MetaTitle]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([MetaDescription]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([MetaKeyword]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([CreateDate]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([ReleaseDate]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([ExpirationDate]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([Version]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([Status]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([IsOnProduction]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([IsMultiSourced]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([IsLinkExternal]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([SpiderDepth]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([UpdateDate]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([UpdateUserID]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([PostedDate]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([DisplayDateMode]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([AuditActionDate]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([AuditActionUserID]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([ReviewedDate]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[AuditNCIView] ([ChangeComments]) TO [webadminuser_role]
GO
