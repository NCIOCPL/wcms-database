SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BestBetCategory]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[BestBetCategory](
	[CategoryID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_BestBetCategories_CategoryID]  DEFAULT (newid()),
	[CatName] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ListID] [uniqueidentifier] NULL,
	[Status] [int] NOT NULL CONSTRAINT [DF_BestBetCategories_Status]  DEFAULT ((1)),
	[Weight] [int] NULL CONSTRAINT [DF_BestBetCategories_Weight]  DEFAULT ((20)),
	[CreateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateDate] [datetime] NULL DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL DEFAULT (getdate()),
 CONSTRAINT [PK_BestBetCategories] PRIMARY KEY CLUSTERED 
(
	[CategoryID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [IX_BestBetCatName] UNIQUE NONCLUSTERED 
(
	[CatName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [UQ_BestBetCategory_CatName] UNIQUE NONCLUSTERED 
(
	[CatName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_BestBetCategories_List]') AND parent_object_id = OBJECT_ID(N'[dbo].[BestBetCategory]'))
ALTER TABLE [dbo].[BestBetCategory]  WITH NOCHECK ADD  CONSTRAINT [FK_BestBetCategories_List] FOREIGN KEY([ListID])
REFERENCES [List] ([ListID])
GO
ALTER TABLE [dbo].[BestBetCategory] CHECK CONSTRAINT [FK_BestBetCategories_List]
GO
