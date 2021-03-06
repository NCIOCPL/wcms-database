SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[AuditNLListItem]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[AuditNLListItem](
	[AuditActionType] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AuditUpdateDate] [datetime] NULL DEFAULT (getdate()),
	[AuditUpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL DEFAULT (user_name()),
	[ListID] [uniqueidentifier] NULL,
	[NCIViewID] [uniqueidentifier] NULL,
	[Title] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ShortTitle] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Description] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsFeatured] [bit] NULL,
	[Priority] [int] NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL
) ON [PRIMARY]
END
GO
