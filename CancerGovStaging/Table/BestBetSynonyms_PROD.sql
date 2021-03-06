SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[BestBetSynonyms_PROD]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BestBetSynonyms_PROD](
	[SynonymID] [uniqueidentifier] NOT NULL,
	[CategoryID] [uniqueidentifier] NOT NULL,
	[SynName] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Weight] [int] NULL,
	[UpdateDate] [datetime] NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsNegated] [bit] NULL,
 CONSTRAINT [PK_BestBetSynonyms_PROD] PRIMARY KEY CLUSTERED 
(
	[SynonymID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[BestBetSynonyms_PROD]') AND name = N'IX_BestBetSynonyms_PROD')
CREATE NONCLUSTERED INDEX [IX_BestBetSynonyms_PROD] ON [dbo].[BestBetSynonyms_PROD] 
(
	[SynonymID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
