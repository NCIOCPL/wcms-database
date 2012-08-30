SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[auditPRODObject]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[auditPRODObject](
	[ObjectID] [uniqueidentifier] NULL,
	[objectTypeID] [int] NULL,
	[OwnerID] [uniqueidentifier] NULL,
	[IsShared] [bit] NULL,
	[IsVirtual] [bit] NULL,
	[title] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[isDirty] [bit] NULL,
	[AuditModifyUser] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL DEFAULT (suser_name()),
	[AuditActionType] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AuditModifyDate] [datetime] NOT NULL DEFAULT (getdate())
) ON [PRIMARY]
END
GO
