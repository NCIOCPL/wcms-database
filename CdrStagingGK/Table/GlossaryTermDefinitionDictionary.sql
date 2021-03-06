SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GlossaryTermDefinitionDictionary]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[GlossaryTermDefinitionDictionary](
	[GlossaryTermDefinitionDictionaryID] [int] IDENTITY(1,1) NOT NULL,
	[GlossaryTermDefinitionID] [int] NOT NULL,
	[Dictionary] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NOT NULL CONSTRAINT [DF_GlossaryTermDefinitionDictionary_UpdateDate]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GlossaryTermDefinitionDictionary_UpdateUserID]  DEFAULT (user_name()),
 CONSTRAINT [PK_GlossaryTermDefinitionDictionary] PRIMARY KEY CLUSTERED 
(
	[GlossaryTermDefinitionDictionaryID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_GlossaryTermDefinitionDictionary_GlossaryTermDefinition]') AND type = 'F')
ALTER TABLE [dbo].[GlossaryTermDefinitionDictionary]  WITH CHECK ADD  CONSTRAINT [FK_GlossaryTermDefinitionDictionary_GlossaryTermDefinition] FOREIGN KEY([GlossaryTermDefinitionID])
REFERENCES [GlossaryTermDefinition] ([GlossaryTermDefinitionID])
GO
ALTER TABLE [dbo].[GlossaryTermDefinitionDictionary] CHECK CONSTRAINT [FK_GlossaryTermDefinitionDictionary_GlossaryTermDefinition]
GO
