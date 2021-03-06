SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ListItem]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ListItem](
	[ListItemInstanceID] [uniqueidentifier] NOT NULL,
	[ListID] [uniqueidentifier] NOT NULL,
	[ListItemID] [uniqueidentifier] NOT NULL,
	[ListItemTypeID] [int] NOT NULL,
	[IsFeatured] [bit] NOT NULL CONSTRAINT [DF_ListItems_IsFeatured]  DEFAULT ((0)),
	[Priority] [int] NOT NULL CONSTRAINT [DF_ListItem_Priority]  DEFAULT ((1)),
	[CreateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateDate] [datetime] NULL DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL DEFAULT (getdate()),
	[OverriddenTitle] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OverriddenShortTitle] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OverriddenDescription] [varchar](1500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OverriddenAnchor] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[overriddenQuery] [varchar](512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FileSize] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FileIcon] [varchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SupplementalText] [varchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_ListItem] PRIMARY KEY NONCLUSTERED 
(
	[ListItemInstanceID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ListItem_List]') AND parent_object_id = OBJECT_ID(N'[dbo].[ListItem]'))
ALTER TABLE [dbo].[ListItem]  WITH CHECK ADD  CONSTRAINT [FK_ListItem_List] FOREIGN KEY([ListID])
REFERENCES [List] ([ListID])
GO
ALTER TABLE [dbo].[ListItem] CHECK CONSTRAINT [FK_ListItem_List]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ListItem_ListItemType]') AND parent_object_id = OBJECT_ID(N'[dbo].[ListItem]'))
ALTER TABLE [dbo].[ListItem]  WITH CHECK ADD  CONSTRAINT [FK_ListItem_ListItemType] FOREIGN KEY([ListItemTypeID])
REFERENCES [ListItemType] ([ListItemTypeID])
GO
ALTER TABLE [dbo].[ListItem] CHECK CONSTRAINT [FK_ListItem_ListItemType]
GO
