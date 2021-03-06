SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TermType]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[TermType](
	[TermID] [uniqueidentifier] NOT NULL,
	[Type] [uniqueidentifier] NOT NULL,
	[TypeOfType] [uniqueidentifier] NOT NULL,
	[UpdateDate] [datetime] NOT NULL CONSTRAINT [DF_TermType_UpdateDate]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TermType_UpdateUserID]  DEFAULT (user_name())
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_term_type_terminology]') AND type = 'F')
ALTER TABLE [dbo].[TermType]  WITH CHECK ADD  CONSTRAINT [FK_term_type_terminology] FOREIGN KEY([TermID])
REFERENCES [Terminology] ([TermID])
GO
ALTER TABLE [dbo].[TermType] CHECK CONSTRAINT [FK_term_type_terminology]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_term_type_type]') AND type = 'F')
ALTER TABLE [dbo].[TermType]  WITH CHECK ADD  CONSTRAINT [FK_term_type_type] FOREIGN KEY([Type])
REFERENCES [Type] ([TypeID])
GO
ALTER TABLE [dbo].[TermType] CHECK CONSTRAINT [FK_term_type_type]
GO
