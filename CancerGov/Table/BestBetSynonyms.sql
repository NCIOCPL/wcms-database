SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[BestBetSynonyms]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BestBetSynonyms](
	[SynonymID] [uniqueidentifier] NOT NULL DEFAULT (newid()),
	[CategoryID] [uniqueidentifier] NOT NULL,
	[SynName] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	--[Weight] [int] NULL DEFAULT (30),
	[UpdateDate] [datetime] NULL DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL DEFAULT (user_name()),
	[IsNegated] [bit] NULL CONSTRAINT [DF_BestBetSynonyms_IsNegated]  DEFAULT (0),
	[Notes] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsExactMatch] [bit] NOT NULL CONSTRAINT [DF_BestBetSynonyms_IsExactMatch]  DEFAULT (0),
PRIMARY KEY CLUSTERED 
(
	[SynonymID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO
