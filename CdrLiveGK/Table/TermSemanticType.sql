SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TermSemanticType]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[TermSemanticType](
	[TermSemanticTypeID] [int] NOT NULL,
	[TermID] [int] NOT NULL,
	[SemanticTypeID] [int] NULL,
	[SemanticTypeName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[TermSemanticType]') AND name = N'CI_termSemantictype')
CREATE CLUSTERED INDEX [CI_termSemantictype] ON [dbo].[TermSemanticType] 
(
	[TermID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_TermSemanticTYpe_terminology]') AND type = 'F')
ALTER TABLE [dbo].[TermSemanticType]  WITH CHECK ADD  CONSTRAINT [FK_TermSemanticTYpe_terminology] FOREIGN KEY([TermID])
REFERENCES [Terminology] ([TermID])
GO
ALTER TABLE [dbo].[TermSemanticType] CHECK CONSTRAINT [FK_TermSemanticTYpe_terminology]
GO
