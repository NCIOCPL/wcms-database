SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Glossary]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[Glossary](
	[GlossaryID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Glossary_GlossaryID]  DEFAULT (newid()),
	[Name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Pronunciation] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Definition] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Status] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Glossary_Status_1]  DEFAULT ('LOADED'),
	[Version] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Glossary_Version]  DEFAULT (0),
	[UpdateDate] [datetime] NOT NULL CONSTRAINT [DF_Glossary_UpdateDate]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Glossary_UpdateUserID]  DEFAULT (user_name()),
	[SourceID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataSource] [char](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_Glossary] PRIMARY KEY NONCLUSTERED 
(
	[GlossaryID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[Glossary]') AND name = N'IX_Glossary')
CREATE CLUSTERED INDEX [IX_Glossary] ON [dbo].[Glossary] 
(
	[Name] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
