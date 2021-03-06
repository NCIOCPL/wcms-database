SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TermAlternateName]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[TermAlternateName](
	[TermID] [uniqueidentifier] NOT NULL,
	[Type] [uniqueidentifier] NOT NULL,
	[Name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[UpdateDate] [datetime] NOT NULL CONSTRAINT [DF_TermAlternateName_UpdateDate]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TermAlternateName_UpdateUserID]  DEFAULT (user_name())
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_TermAlternateName_Terminology]') AND type = 'F')
ALTER TABLE [dbo].[TermAlternateName]  WITH CHECK ADD  CONSTRAINT [FK_TermAlternateName_Terminology] FOREIGN KEY([TermID])
REFERENCES [Terminology] ([TermID])
GO
ALTER TABLE [dbo].[TermAlternateName] CHECK CONSTRAINT [FK_TermAlternateName_Terminology]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_TermAlternateName_Type]') AND type = 'F')
ALTER TABLE [dbo].[TermAlternateName]  WITH CHECK ADD  CONSTRAINT [FK_TermAlternateName_Type] FOREIGN KEY([Type])
REFERENCES [Type] ([TypeID])
GO
ALTER TABLE [dbo].[TermAlternateName] CHECK CONSTRAINT [FK_TermAlternateName_Type]
GO
