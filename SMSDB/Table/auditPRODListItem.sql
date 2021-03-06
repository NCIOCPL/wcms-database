SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[auditPRODListItem]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[auditPRODListItem](
	[ListItemInstanceID] [uniqueidentifier] NULL,
	[ListID] [uniqueidentifier] NULL,
	[ListItemID] [uniqueidentifier] NULL,
	[ListItemTypeID] [int] NULL,
	[IsFeatured] [bit] NULL,
	[Priority] [int] NULL,
	[CreateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateDate] [datetime] NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL,
	[overriddenTitle] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[overriddenshortTitle] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[overriddenDescription] [varchar](1500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OverriddenAnchor] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[overriddenQuery] [varchar](512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FileSize] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FileIcon] [varchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SupplementalText] [varchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AuditModifyUser] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL DEFAULT (suser_name()),
	[AuditActionType] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AuditModifyDate] [datetime] NOT NULL DEFAULT (getdate())
) ON [PRIMARY]
END
GO
