SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PRODListItem]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PRODListItem](
	[ListItemInstanceID] [uniqueidentifier] NOT NULL,
	[ListID] [uniqueidentifier] NOT NULL,
	[ListItemID] [uniqueidentifier] NOT NULL,
	[ListItemTypeID] [int] NOT NULL,
	[IsFeatured] [bit] NOT NULL CONSTRAINT [DF_PRODListItems_IsFeatured]  DEFAULT ((0)),
	[Priority] [int] NOT NULL CONSTRAINT [DF_PRODListItem_Priority]  DEFAULT ((1)),
	[CreateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateDate] [datetime] NULL DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL DEFAULT (getdate()),
	[overriddenTitle] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[overriddenshortTitle] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[overriddenDescription] [varchar](1500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OverriddenAnchor] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[overriddenQuery] [varchar](512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FileSize] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FileIcon] [varchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SupplementalText] [varchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_PRODListItem] PRIMARY KEY NONCLUSTERED 
(
	[ListItemInstanceID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PRODListItem_List]') AND parent_object_id = OBJECT_ID(N'[dbo].[PRODListItem]'))
ALTER TABLE [dbo].[PRODListItem]  WITH CHECK ADD  CONSTRAINT [FK_PRODListItem_List] FOREIGN KEY([ListID])
REFERENCES [PRODList] ([ListID])
GO
ALTER TABLE [dbo].[PRODListItem] CHECK CONSTRAINT [FK_PRODListItem_List]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PRODListItem_ListItemType]') AND parent_object_id = OBJECT_ID(N'[dbo].[PRODListItem]'))
ALTER TABLE [dbo].[PRODListItem]  WITH CHECK ADD  CONSTRAINT [FK_PRODListItem_ListItemType] FOREIGN KEY([ListItemTypeID])
REFERENCES [ListItemType] ([ListItemTypeID])
GO
ALTER TABLE [dbo].[PRODListItem] CHECK CONSTRAINT [FK_PRODListItem_ListItemType]
GO
