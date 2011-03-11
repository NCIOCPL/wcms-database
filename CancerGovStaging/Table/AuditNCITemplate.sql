SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[AuditNCITemplate]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[AuditNCITemplate](
	[AuditActionType] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[NCITemplateID] [uniqueidentifier] NOT NULL,
	[Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[URL] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Description] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AddURL] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EditURL] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AuditActionDate] [datetime] NOT NULL DEFAULT (getdate()),
	[AuditActionUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL DEFAULT (user_name())
) ON [PRIMARY]
END
GO
