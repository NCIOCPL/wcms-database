SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PRODObject]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PRODObject](
	[ObjectID] [uniqueidentifier] NOT NULL,
	[objectTypeID] [int] NULL,
	[OwnerID] [uniqueidentifier] NULL,
	[IsShared] [bit] NULL CONSTRAINT [DF_PRODObject_IsShared]  DEFAULT ((0)),
	[IsVirtual] [bit] NULL,
	[title] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[isDirty] [bit] NOT NULL DEFAULT ((1)),
 CONSTRAINT [PK_PRODObject] PRIMARY KEY CLUSTERED 
(
	[ObjectID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PRODObject_NodeID]') AND parent_object_id = OBJECT_ID(N'[dbo].[PRODObject]'))
ALTER TABLE [dbo].[PRODObject]  WITH CHECK ADD  CONSTRAINT [FK_PRODObject_NodeID] FOREIGN KEY([OwnerID])
REFERENCES [PRODNode] ([NodeID])
GO
ALTER TABLE [dbo].[PRODObject] CHECK CONSTRAINT [FK_PRODObject_NodeID]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PRODObject_objectType]') AND parent_object_id = OBJECT_ID(N'[dbo].[PRODObject]'))
ALTER TABLE [dbo].[PRODObject]  WITH CHECK ADD  CONSTRAINT [FK_PRODObject_objectType] FOREIGN KEY([objectTypeID])
REFERENCES [ObjectType] ([ObjectTypeID])
GO
ALTER TABLE [dbo].[PRODObject] CHECK CONSTRAINT [FK_PRODObject_objectType]
GO
