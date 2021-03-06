SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[NLListItem]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[NLListItem](
	[ListID] [uniqueidentifier] NOT NULL DEFAULT (newid()),
	[NCIViewID] [uniqueidentifier] NOT NULL,
	[Title] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ShortTitle] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Description] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsFeatured] [bit] NULL,
	[Priority] [int] NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL DEFAULT (user_name()),
	[UpdateDate] [datetime] NULL DEFAULT (getdate()),
 CONSTRAINT [PK_NLListItem] PRIMARY KEY CLUSTERED 
(
	[ListID] ASC,
	[NCIViewID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_NLListItem_List]') AND type = 'F')
ALTER TABLE [dbo].[NLListItem]  WITH NOCHECK ADD  CONSTRAINT [FK_NLListItem_List] FOREIGN KEY([ListID])
REFERENCES [List] ([ListID])
GO
ALTER TABLE [dbo].[NLListItem] CHECK CONSTRAINT [FK_NLListItem_List]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_NLListItem_NCIView]') AND type = 'F')
ALTER TABLE [dbo].[NLListItem]  WITH CHECK ADD  CONSTRAINT [FK_NLListItem_NCIView] FOREIGN KEY([NCIViewID])
REFERENCES [NCIView] ([NCIViewID])
GO
ALTER TABLE [dbo].[NLListItem] CHECK CONSTRAINT [FK_NLListItem_NCIView]
GO
