SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PRODNodeProperty]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PRODNodeProperty](
	[NodePropertyID] [uniqueidentifier] NOT NULL,
	[NodeID] [uniqueidentifier] NOT NULL,
	[PropertyTemplateID] [uniqueidentifier] NOT NULL,
	[PropertyValue] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateDate] [datetime] NULL DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL DEFAULT (getdate()),
 CONSTRAINT [PK_PRODNodeProperties] PRIMARY KEY NONCLUSTERED 
(
	[NodePropertyID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PRODNodeProperties_Node]') AND parent_object_id = OBJECT_ID(N'[dbo].[PRODNodeProperty]'))
ALTER TABLE [dbo].[PRODNodeProperty]  WITH CHECK ADD  CONSTRAINT [FK_PRODNodeProperties_Node] FOREIGN KEY([NodeID])
REFERENCES [PRODNode] ([NodeID])
GO
ALTER TABLE [dbo].[PRODNodeProperty] CHECK CONSTRAINT [FK_PRODNodeProperties_Node]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PRODNodeProperties_PropertyTemplates]') AND parent_object_id = OBJECT_ID(N'[dbo].[PRODNodeProperty]'))
ALTER TABLE [dbo].[PRODNodeProperty]  WITH CHECK ADD  CONSTRAINT [FK_PRODNodeProperties_PropertyTemplates] FOREIGN KEY([PropertyTemplateID])
REFERENCES [PropertyTemplate] ([PropertyTemplateID])
GO
ALTER TABLE [dbo].[PRODNodeProperty] CHECK CONSTRAINT [FK_PRODNodeProperties_PropertyTemplates]
GO
