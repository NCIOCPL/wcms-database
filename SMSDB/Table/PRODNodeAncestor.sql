SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PRODNodeAncestor]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PRODNodeAncestor](
	[NodeID] [uniqueidentifier] NULL,
	[AncestorNodeID] [uniqueidentifier] NULL,
	[TreeLevel] [tinyint] NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[PRODNodeAncestor]') AND name = N'CI_PRODNodeAncestor')
CREATE CLUSTERED INDEX [CI_PRODNodeAncestor] ON [dbo].[PRODNodeAncestor] 
(
	[NodeID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
