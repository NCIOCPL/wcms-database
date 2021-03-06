SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[List]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[List](
	[ListID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_StagingList_ListID]  DEFAULT (newid()),
	[GroupID] [int] NULL,
	[ListName] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ListDesc] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[URL] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParentListID] [uniqueidentifier] NULL,
	[NCIViewID] [uniqueidentifier] NULL,
	[Priority] [int] NULL CONSTRAINT [DF_StagingList_Priority]  DEFAULT (1000),
	[UpdateDate] [datetime] NULL CONSTRAINT [DF_StagingList_UpdateDate1]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_List_UpdateUserID]  DEFAULT (user_name()),
	[DescDisplay] [bit] NULL CONSTRAINT [DF_List_DescDisplay]  DEFAULT (0),
	[ReleaseDateDisplay] [bit] NULL CONSTRAINT [DF_List_ReleaseDateDisplay]  DEFAULT (0),
	[ReleaseDateDisplayLoc] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_StagingList] PRIMARY KEY NONCLUSTERED 
(
	[ListID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[List]') AND name = N'IX_StagingList_ParentListID')
CREATE NONCLUSTERED INDEX [IX_StagingList_ParentListID] ON [dbo].[List] 
(
	[ParentListID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
GRANT SELECT ON [dbo].[List] TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[List] ([ListID]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[List] ([GroupID]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[List] ([ListName]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[List] ([ListDesc]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[List] ([URL]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[List] ([ParentListID]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[List] ([NCIViewID]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[List] ([Priority]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[List] ([UpdateDate]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[List] ([UpdateUserID]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[List] ([DescDisplay]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[List] ([ReleaseDateDisplay]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[List] ([ReleaseDateDisplayLoc]) TO [webadminuser_role]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_List_List]') AND type = 'F')
ALTER TABLE [dbo].[List]  WITH NOCHECK ADD  CONSTRAINT [FK_List_List] FOREIGN KEY([ParentListID])
REFERENCES [List] ([ListID])
GO
ALTER TABLE [dbo].[List] CHECK CONSTRAINT [FK_List_List]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_List_NCIView]') AND type = 'F')
ALTER TABLE [dbo].[List]  WITH NOCHECK ADD  CONSTRAINT [FK_List_NCIView] FOREIGN KEY([NCIViewID])
REFERENCES [NCIView] ([NCIViewID])
GO
ALTER TABLE [dbo].[List] CHECK CONSTRAINT [FK_List_NCIView]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_StagingList_Groups]') AND type = 'F')
ALTER TABLE [dbo].[List]  WITH NOCHECK ADD  CONSTRAINT [FK_StagingList_Groups] FOREIGN KEY([GroupID])
REFERENCES [Groups] ([GroupID])
GO
ALTER TABLE [dbo].[List] CHECK CONSTRAINT [FK_StagingList_Groups]
GO
