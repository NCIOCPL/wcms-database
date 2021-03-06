SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GlossaryTermDefinition]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[GlossaryTermDefinition](
	[GlossaryTermDefinitionID] [int] IDENTITY(1,1) NOT NULL,
	[GlossaryTermID] [int] NOT NULL,
	[DefinitionText] [varchar](3900) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DefinitionHTML] [varchar](3900) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Language] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GlossaryTermDefinition_Language]  DEFAULT ('English'),
	[UpdateDate] [datetime] NOT NULL CONSTRAINT [DF_GlossaryTermDefinition_UpdateDate]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GlossaryTermDefinition_UpdateUserID]  DEFAULT (user_name()),
	[MediaHTML] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	AudioMediaHTML ntext,
	RelatedInformationHtml ntext,	
	MediaCaption nvarchar(max), 
	MediaID int,
 CONSTRAINT [PK_GlossaryTermDefinition] PRIMARY KEY CLUSTERED 
(
	[GlossaryTermDefinitionID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_GlossaryTermDefinition_GlossaryTerm]') AND type = 'F')
ALTER TABLE [dbo].[GlossaryTermDefinition]  WITH CHECK ADD  CONSTRAINT [FK_GlossaryTermDefinition_GlossaryTerm] FOREIGN KEY([GlossaryTermID])
REFERENCES [GlossaryTerm] ([GlossaryTermID])
GO
ALTER TABLE [dbo].[GlossaryTermDefinition] CHECK CONSTRAINT [FK_GlossaryTermDefinition_GlossaryTerm]
GO
