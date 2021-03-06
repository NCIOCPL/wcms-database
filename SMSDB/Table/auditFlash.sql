SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[auditFlash]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[auditFlash](
	[FlashObjectID] [uniqueidentifier] NULL,
	[Title] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SrcUrl] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Width] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Height] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RequiredVersion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BackgroundColor] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AlternateHtml] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateDate] [datetime] NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL,
	[AuditModifyUser] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL DEFAULT (suser_name()),
	[AuditActionType] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AuditModifyDate] [datetime] NOT NULL DEFAULT (getdate())
) ON [PRIMARY]
END
GO
