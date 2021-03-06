SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[auditNode]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[auditNode](
	[NodeID] [uniqueidentifier] NULL,
	[Title] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ShortTitle] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Description] [varchar](1500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParentNodeID] [uniqueidentifier] NULL,
	[ShowInNavigation] [bit] NULL,
	[ShowInBreadCrumbs] [bit] NULL,
	[Priority] [int] NULL,
	[CreateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateDate] [datetime] NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL,
	[status] [int] NULL,
	[isPublished] [bit] NULL,
	[DisplayPostedDate] [datetime] NULL,
	[DisplayUpdateDate] [datetime] NULL,
	[DisplayReviewDate] [datetime] NULL,
	[DisplayExpirationDate] [datetime] NULL,
	[DisplayDateMode] [tinyint] NULL,
	[AuditModifyUser] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL DEFAULT (suser_name()),
	[AuditActionType] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AuditModifyDate] [datetime] NOT NULL DEFAULT (getdate())
) ON [PRIMARY]
END
GO
