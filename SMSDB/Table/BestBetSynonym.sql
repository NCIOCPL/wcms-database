SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BestBetSynonym]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[BestBetSynonym](
	[SynonymID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_BestBetSynonyms_SynonymID]  DEFAULT (newid()),
	[CategoryID] [uniqueidentifier] NOT NULL,
	[SynName] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsNegated] [bit] NULL CONSTRAINT [DF_BestBetSynonyms_IsNegated]  DEFAULT ((0)),
	[CreateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateDate] [datetime] NULL DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL DEFAULT (getdate()),
 CONSTRAINT [PK_BestBetsSynonyms] PRIMARY KEY CLUSTERED 
(
	[SynonymID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [IX_BestBetsSynNameCatID] UNIQUE NONCLUSTERED 
(
	[CategoryID] ASC,
	[SynName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [UQ_bestbetsynonym_synName] UNIQUE NONCLUSTERED 
(
	[CategoryID] ASC,
	[SynName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_BestBetsSynonyms_BestBetCategories]') AND parent_object_id = OBJECT_ID(N'[dbo].[BestBetSynonym]'))
ALTER TABLE [dbo].[BestBetSynonym]  WITH NOCHECK ADD  CONSTRAINT [FK_BestBetsSynonyms_BestBetCategories] FOREIGN KEY([CategoryID])
REFERENCES [BestBetCategory] ([CategoryID])
GO
ALTER TABLE [dbo].[BestBetSynonym] CHECK CONSTRAINT [FK_BestBetsSynonyms_BestBetCategories]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[ck_bestbetsynonym_SynName]') AND parent_object_id = OBJECT_ID(N'[dbo].[BestBetSynonym]'))
ALTER TABLE [dbo].[BestBetSynonym]  WITH CHECK ADD  CONSTRAINT [ck_bestbetsynonym_SynName] CHECK  (([dbo].[Bestbet_Function_SynNameCK]([synonymID],[synName])=(1)))
GO
ALTER TABLE [dbo].[BestBetSynonym] CHECK CONSTRAINT [ck_bestbetsynonym_SynName]
GO
