SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PageLink]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PageLink](
	[LinkID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PageLink_LinkID]  DEFAULT (newid()),
	[NodeID] [uniqueidentifier] NOT NULL,
	[OverrideTitle] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OverrideShortTitle] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OverrideDescription] [varchar](1500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Anchor] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateDate] [datetime] NULL DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL DEFAULT (getdate()),
 CONSTRAINT [PK_PageLink] PRIMARY KEY CLUSTERED 
(
	[LinkID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PageLink_NodeID]') AND parent_object_id = OBJECT_ID(N'[dbo].[PageLink]'))
ALTER TABLE [dbo].[PageLink]  WITH CHECK ADD  CONSTRAINT [FK_PageLink_NodeID] FOREIGN KEY([NodeID])
REFERENCES [Node] ([NodeID])
GO
ALTER TABLE [dbo].[PageLink] CHECK CONSTRAINT [FK_PageLink_NodeID]
GO
