SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayoutDefinition]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[LayoutDefinition](
	[NodeID] [uniqueidentifier] NOT NULL,
	[LayoutTemplateID] [uniqueidentifier] NOT NULL,
	[ContentAreaTemplateID] [uniqueidentifier] NOT NULL,
	[CreateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateDate] [datetime] NULL DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL DEFAULT (getdate()),
 CONSTRAINT [PK_layoutDefinition] PRIMARY KEY CLUSTERED 
(
	[NodeID] ASC,
	[LayoutTemplateID] ASC,
	[ContentAreaTemplateID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_LayoutDefinition_ContentAreaTemplates]') AND parent_object_id = OBJECT_ID(N'[dbo].[LayoutDefinition]'))
ALTER TABLE [dbo].[LayoutDefinition]  WITH CHECK ADD  CONSTRAINT [FK_LayoutDefinition_ContentAreaTemplates] FOREIGN KEY([ContentAreaTemplateID])
REFERENCES [ContentAreaTemplate] ([ContentAreaTemplateID])
GO
ALTER TABLE [dbo].[LayoutDefinition] CHECK CONSTRAINT [FK_LayoutDefinition_ContentAreaTemplates]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_LayoutDefinition_LayoutTemplate]') AND parent_object_id = OBJECT_ID(N'[dbo].[LayoutDefinition]'))
ALTER TABLE [dbo].[LayoutDefinition]  WITH CHECK ADD  CONSTRAINT [FK_LayoutDefinition_LayoutTemplate] FOREIGN KEY([LayoutTemplateID])
REFERENCES [LayoutTemplate] ([LayoutTemplateID])
GO
ALTER TABLE [dbo].[LayoutDefinition] CHECK CONSTRAINT [FK_LayoutDefinition_LayoutTemplate]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_LayoutDefinition_Node]') AND parent_object_id = OBJECT_ID(N'[dbo].[LayoutDefinition]'))
ALTER TABLE [dbo].[LayoutDefinition]  WITH CHECK ADD  CONSTRAINT [FK_LayoutDefinition_Node] FOREIGN KEY([NodeID])
REFERENCES [Node] ([NodeID])
GO
ALTER TABLE [dbo].[LayoutDefinition] CHECK CONSTRAINT [FK_LayoutDefinition_Node]
GO
