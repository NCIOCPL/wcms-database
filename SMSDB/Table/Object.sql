SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Object]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Object](
	[ObjectID] [uniqueidentifier] NOT NULL,
	[objectTypeID] [int] NULL,
	[OwnerID] [uniqueidentifier] NULL,
	[IsShared] [bit] NULL CONSTRAINT [DF_Object_IsShared]  DEFAULT ((0)),
	[IsVirtual] [bit] NULL,
	[isDirty] [bit] NOT NULL DEFAULT ((1)),
	[title] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_Object] PRIMARY KEY CLUSTERED 
(
	[ObjectID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Object_NodeID]') AND parent_object_id = OBJECT_ID(N'[dbo].[Object]'))
ALTER TABLE [dbo].[Object]  WITH CHECK ADD  CONSTRAINT [FK_Object_NodeID] FOREIGN KEY([OwnerID])
REFERENCES [Node] ([NodeID])
GO
ALTER TABLE [dbo].[Object] CHECK CONSTRAINT [FK_Object_NodeID]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Object_objectType]') AND parent_object_id = OBJECT_ID(N'[dbo].[Object]'))
ALTER TABLE [dbo].[Object]  WITH CHECK ADD  CONSTRAINT [FK_Object_objectType] FOREIGN KEY([objectTypeID])
REFERENCES [ObjectType] ([ObjectTypeID])
GO
ALTER TABLE [dbo].[Object] CHECK CONSTRAINT [FK_Object_objectType]
GO
