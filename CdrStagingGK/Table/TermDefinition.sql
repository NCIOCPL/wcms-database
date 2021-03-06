SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TermDefinition]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[TermDefinition](
	[TermDefinitionID] [int] IDENTITY(1,1) NOT NULL,
	[TermID] [int] NULL,
	[Definition] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DefinitionType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Comment] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DefinitionHTML] [nvarchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[TermDefinition]') AND name = N'CI_termdefinition')
CREATE CLUSTERED INDEX [CI_termdefinition] ON [dbo].[TermDefinition] 
(
	[TermID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_TermDefinition_Terminology]') AND type = 'F')
ALTER TABLE [dbo].[TermDefinition]  WITH CHECK ADD  CONSTRAINT [FK_TermDefinition_Terminology] FOREIGN KEY([TermID])
REFERENCES [Terminology] ([TermID])
GO
ALTER TABLE [dbo].[TermDefinition] CHECK CONSTRAINT [FK_TermDefinition_Terminology]
GO
