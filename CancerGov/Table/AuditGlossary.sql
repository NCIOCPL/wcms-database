SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[AuditGlossary]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[AuditGlossary](
	[AuditActionType] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[GlossaryID] [uniqueidentifier] NOT NULL,
	[Name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Pronunciation] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Definition] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Status] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Version] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SourceID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataSource] [char](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AuditActionDate] [datetime] NOT NULL CONSTRAINT [DF_AuditGlossary_AuditActionDate]  DEFAULT (getdate()),
	[AuditActionUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AuditGlossary_AuditActionUserID]  DEFAULT (user_name())
) ON [PRIMARY]
END
GO
