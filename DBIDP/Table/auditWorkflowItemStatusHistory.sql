SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[auditWorkflowItemStatusHistory]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[auditWorkflowItemStatusHistory](
	[WorkflowItemID] [uniqueidentifier] NULL,
	[Action] [int] NULL,
	[PostActionStatus] [int] NULL,
	[ActionBy] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Date] [datetime] NULL,
	[Comment] [varchar](2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AuditModifyUser] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL DEFAULT (suser_name()),
	[AuditActionType] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AuditModifyDate] [datetime] NOT NULL DEFAULT (getdate())
) ON [PRIMARY]
END
GO
