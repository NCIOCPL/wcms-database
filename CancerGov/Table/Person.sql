SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Person]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[Person](
	[PersonID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Person_PersonID]  DEFAULT (newid()),
	[GivenName] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GivenNameInitials] [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Surname] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[GenerationakSuffix] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Type] [uniqueidentifier] NOT NULL,
	[StatusID] [uniqueidentifier] NULL,
	[IsActive] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Person_IsActive]  DEFAULT ('Y'),
	[Retired] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Person_Retired]  DEFAULT ('N'),
	[Deceased] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Person_Deceased]  DEFAULT ('N'),
	[DoesNotTreat] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Person_DoesNotTreat]  DEFAULT ('N'),
	[Contact_At_Home] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Person_Contact_At_Home]  DEFAULT ('N'),
	[Comments] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NOT NULL CONSTRAINT [DF_Person_UpdateDate]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Person_UpdateUserID]  DEFAULT (user_name()),
	[SourceID] [numeric](18, 0) NULL,
	[DataSource] [char](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_person] PRIMARY KEY NONCLUSTERED 
(
	[PersonID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[Person]') AND name = N'IX_Person_SourceID_DataSource')
CREATE NONCLUSTERED INDEX [IX_Person_SourceID_DataSource] ON [dbo].[Person] 
(
	[SourceID] ASC,
	[DataSource] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_Person_Status]') AND type = 'F')
ALTER TABLE [dbo].[Person]  WITH CHECK ADD  CONSTRAINT [FK_Person_Status] FOREIGN KEY([StatusID])
REFERENCES [Status] ([StatusID])
GO
ALTER TABLE [dbo].[Person] CHECK CONSTRAINT [FK_Person_Status]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_person_type]') AND type = 'F')
ALTER TABLE [dbo].[Person]  WITH CHECK ADD  CONSTRAINT [FK_person_type] FOREIGN KEY([Type])
REFERENCES [Type] ([TypeID])
GO
ALTER TABLE [dbo].[Person] CHECK CONSTRAINT [FK_person_type]
GO
