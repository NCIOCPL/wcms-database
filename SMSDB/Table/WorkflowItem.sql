SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WorkflowItem]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[WorkflowItem](
	[WorkflowItemID] [uniqueidentifier] NOT NULL,
	[URL] [varchar](512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Title] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_WorkItem] PRIMARY KEY CLUSTERED 
(
	[WorkflowItemID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
