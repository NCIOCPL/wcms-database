SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TermRelations]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[TermRelations](
	[TermID] [uniqueidentifier] NOT NULL,
	[RelatedTermID] [uniqueidentifier] NOT NULL,
	[RelationType] [uniqueidentifier] NULL,
	[ProductID] [uniqueidentifier] NULL,
	[UpdateDate] [datetime] NOT NULL CONSTRAINT [DF_TermRelations_UpdateDate]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TermRelations_UpdateUserID]  DEFAULT (user_name())
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[TermRelations]') AND name = N'IX_TermRelations')
CREATE NONCLUSTERED INDEX [IX_TermRelations] ON [dbo].[TermRelations] 
(
	[TermID] ASC,
	[RelationType] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_term_relation_terminology]') AND type = 'F')
ALTER TABLE [dbo].[TermRelations]  WITH CHECK ADD  CONSTRAINT [FK_term_relation_terminology] FOREIGN KEY([TermID])
REFERENCES [Terminology] ([TermID])
GO
ALTER TABLE [dbo].[TermRelations] CHECK CONSTRAINT [FK_term_relation_terminology]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_term_relation_terminology1]') AND type = 'F')
ALTER TABLE [dbo].[TermRelations]  WITH CHECK ADD  CONSTRAINT [FK_term_relation_terminology1] FOREIGN KEY([RelatedTermID])
REFERENCES [Terminology] ([TermID])
GO
ALTER TABLE [dbo].[TermRelations] CHECK CONSTRAINT [FK_term_relation_terminology1]
GO
