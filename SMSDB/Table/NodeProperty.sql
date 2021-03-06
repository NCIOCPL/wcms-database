SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[NodeProperty]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[NodeProperty](
	[NodePropertyID] [uniqueidentifier] NOT NULL,
	[NodeID] [uniqueidentifier] NOT NULL,
	[PropertyTemplateID] [uniqueidentifier] NOT NULL,
	[CreateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateDate] [datetime] NULL DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL DEFAULT (getdate()),
	[PropertyValue] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL DEFAULT (' '),
 CONSTRAINT [PK_NodeProperties] PRIMARY KEY NONCLUSTERED 
(
	[NodePropertyID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[NodeProperty]') AND name = N'CI_NodeProperty')
CREATE CLUSTERED INDEX [CI_NodeProperty] ON [dbo].[NodeProperty] 
(
	[NodeID] ASC,
	[PropertyTemplateID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_NodeProperties_Node]') AND parent_object_id = OBJECT_ID(N'[dbo].[NodeProperty]'))
ALTER TABLE [dbo].[NodeProperty]  WITH CHECK ADD  CONSTRAINT [FK_NodeProperties_Node] FOREIGN KEY([NodeID])
REFERENCES [Node] ([NodeID])
GO
ALTER TABLE [dbo].[NodeProperty] CHECK CONSTRAINT [FK_NodeProperties_Node]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_NodeProperties_PropertyTemplates]') AND parent_object_id = OBJECT_ID(N'[dbo].[NodeProperty]'))
ALTER TABLE [dbo].[NodeProperty]  WITH CHECK ADD  CONSTRAINT [FK_NodeProperties_PropertyTemplates] FOREIGN KEY([PropertyTemplateID])
REFERENCES [PropertyTemplate] ([PropertyTemplateID])
GO
ALTER TABLE [dbo].[NodeProperty] CHECK CONSTRAINT [FK_NodeProperties_PropertyTemplates]
GO
