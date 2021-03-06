SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[AuditImage]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[AuditImage](
	[AuditActionType] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AuditActionDate] [datetime] NOT NULL CONSTRAINT [DF_AuditImage_AuditActionDate_1]  DEFAULT (getdate()),
	[AuditActionUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_AuditImage_AuditActionUserID_1]  DEFAULT (user_name()),
	[ImageID] [uniqueidentifier] NULL,
	[ImageName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ImageSource] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ImageAltText] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TextSource] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Url] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Width] [int] NULL,
	[Height] [int] NULL,
	[Border] [int] NULL,
	[UpdateDate] [datetime] NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
END
GO
