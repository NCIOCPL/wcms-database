SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Task]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[Task](
	[TaskID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Task_TaskID]  DEFAULT (newid()),
	[ResponsibleGroupID] [int] NULL,
	[Name] [varchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Status] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Task_Status]  DEFAULT ('READY'),
	[Notes] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Importance] [char](7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Task_Importance]  DEFAULT ('Medium'),
	[ObjectID] [uniqueidentifier] NULL,
	[UpdateDate] [datetime] NOT NULL CONSTRAINT [DF_Task_UpdateDate]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Task_UpdateUserID]  DEFAULT (user_name()),
 CONSTRAINT [PK_Task] PRIMARY KEY CLUSTERED 
(
	[TaskID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[Task]') AND name = N'IX_Task')
CREATE NONCLUSTERED INDEX [IX_Task] ON [dbo].[Task] 
(
	[ResponsibleGroupID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_Task_Groups]') AND type = 'F')
ALTER TABLE [dbo].[Task]  WITH CHECK ADD  CONSTRAINT [FK_Task_Groups] FOREIGN KEY([ResponsibleGroupID])
REFERENCES [Groups] ([GroupID])
GO
ALTER TABLE [dbo].[Task] CHECK CONSTRAINT [FK_Task_Groups]
GO
