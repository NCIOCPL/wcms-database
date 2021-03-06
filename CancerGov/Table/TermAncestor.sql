SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TermAncestor]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[TermAncestor](
	[TermID] [uniqueidentifier] NOT NULL,
	[AncestorID] [uniqueidentifier] NOT NULL,
	[ProductTypeID] [uniqueidentifier] NOT NULL,
	[AncestorLevel] [int] NOT NULL,
	[UpdateDate] [datetime] NOT NULL CONSTRAINT [DF_TermAncestor_UpdateDate]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TermAncestor_UpdateUserID]  DEFAULT (user_name())
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[TermAncestor]') AND name = N'TermAncestor3')
CREATE CLUSTERED INDEX [TermAncestor3] ON [dbo].[TermAncestor] 
(
	[TermID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[TermAncestor]') AND name = N'IX_TermAncestor_JuatA')
CREATE NONCLUSTERED INDEX [IX_TermAncestor_JuatA] ON [dbo].[TermAncestor] 
(
	[AncestorID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[TermAncestor]') AND name = N'IX_TermAncestor_TA')
CREATE NONCLUSTERED INDEX [IX_TermAncestor_TA] ON [dbo].[TermAncestor] 
(
	[TermID] ASC,
	[AncestorID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_TermAncestor_Terminology]') AND type = 'F')
ALTER TABLE [dbo].[TermAncestor]  WITH CHECK ADD  CONSTRAINT [FK_TermAncestor_Terminology] FOREIGN KEY([TermID])
REFERENCES [Terminology] ([TermID])
GO
ALTER TABLE [dbo].[TermAncestor] CHECK CONSTRAINT [FK_TermAncestor_Terminology]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_TermAncestor_Terminology1]') AND type = 'F')
ALTER TABLE [dbo].[TermAncestor]  WITH CHECK ADD  CONSTRAINT [FK_TermAncestor_Terminology1] FOREIGN KEY([AncestorID])
REFERENCES [Terminology] ([TermID])
GO
ALTER TABLE [dbo].[TermAncestor] CHECK CONSTRAINT [FK_TermAncestor_Terminology1]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_TermAncestor_Type]') AND type = 'F')
ALTER TABLE [dbo].[TermAncestor]  WITH CHECK ADD  CONSTRAINT [FK_TermAncestor_Type] FOREIGN KEY([ProductTypeID])
REFERENCES [Type] ([TypeID])
GO
ALTER TABLE [dbo].[TermAncestor] CHECK CONSTRAINT [FK_TermAncestor_Type]
GO
