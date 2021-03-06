SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PRODNode]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PRODNode](
	[NodeID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PRODNodes_NodeID]  DEFAULT (newid()),
	[Title] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ShortTitle] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Description] [varchar](1500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParentNodeID] [uniqueidentifier] NULL,
	[ShowInNavigation] [bit] NOT NULL,
	[ShowInBreadCrumbs] [bit] NOT NULL,
	[Priority] [int] NOT NULL,
	[CreateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateDate] [datetime] NULL CONSTRAINT [DF__PRODNode_CreateDate]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL CONSTRAINT [DF__PRODNode_UpdateDate]  DEFAULT (getdate()),
	[status] [int] NOT NULL DEFAULT ((1)),
	[isPublished] [bit] NOT NULL DEFAULT ((0)),
	[DisplayPostedDate] [datetime] NULL CONSTRAINT [DF_PRODnode_Posteddate]  DEFAULT ('1/1/1980'),
	[DisplayUpdateDate] [datetime] NULL CONSTRAINT [DF_PRODnode_DisplayUpdateDate]  DEFAULT ('1/1/1980'),
	[DisplayReviewDate] [datetime] NULL CONSTRAINT [DF_PRODnode_reviewdate]  DEFAULT ('1/1/1980'),
	[DisplayExpirationDate] [datetime] NULL CONSTRAINT [DF_PRODnode_expirationdate]  DEFAULT ('1/1/2100'),
	[DisplayDateMode] [tinyint] NOT NULL CONSTRAINT [DF_PRODnode_DisplayDateMode]  DEFAULT ((0)),
 CONSTRAINT [PK_PRODNode] PRIMARY KEY CLUSTERED 
(
	[NodeID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PRODNode_Node]') AND parent_object_id = OBJECT_ID(N'[dbo].[PRODNode]'))
ALTER TABLE [dbo].[PRODNode]  WITH CHECK ADD  CONSTRAINT [FK_PRODNode_Node] FOREIGN KEY([ParentNodeID])
REFERENCES [PRODNode] ([NodeID])
GO
ALTER TABLE [dbo].[PRODNode] CHECK CONSTRAINT [FK_PRODNode_Node]
GO
