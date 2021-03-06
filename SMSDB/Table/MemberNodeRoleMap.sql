SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MemberNodeRoleMap]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[MemberNodeRoleMap](
	[RoleID] [bigint] NOT NULL,
	[MemberID] [uniqueidentifier] NOT NULL,
	[NodeID] [uniqueidentifier] NOT NULL,
	[CreateDate] [datetime] NULL,
	[CreateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_MemberNodeRoleMap] PRIMARY KEY CLUSTERED 
(
	[NodeID] ASC,
	[MemberID] ASC,
	[RoleID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_MemberNodeRoleMap_Members]') AND parent_object_id = OBJECT_ID(N'[dbo].[MemberNodeRoleMap]'))
ALTER TABLE [dbo].[MemberNodeRoleMap]  WITH CHECK ADD  CONSTRAINT [FK_MemberNodeRoleMap_Members] FOREIGN KEY([MemberID])
REFERENCES [Member] ([MemberID])
GO
ALTER TABLE [dbo].[MemberNodeRoleMap] CHECK CONSTRAINT [FK_MemberNodeRoleMap_Members]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_MemberNodeRoleMap_Nodes]') AND parent_object_id = OBJECT_ID(N'[dbo].[MemberNodeRoleMap]'))
ALTER TABLE [dbo].[MemberNodeRoleMap]  WITH CHECK ADD  CONSTRAINT [FK_MemberNodeRoleMap_Nodes] FOREIGN KEY([NodeID])
REFERENCES [Node] ([NodeID])
GO
ALTER TABLE [dbo].[MemberNodeRoleMap] CHECK CONSTRAINT [FK_MemberNodeRoleMap_Nodes]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_MemberNodeRoleMap_Roles]') AND parent_object_id = OBJECT_ID(N'[dbo].[MemberNodeRoleMap]'))
ALTER TABLE [dbo].[MemberNodeRoleMap]  WITH CHECK ADD  CONSTRAINT [FK_MemberNodeRoleMap_Roles] FOREIGN KEY([RoleID])
REFERENCES [Role] ([RoleID])
GO
ALTER TABLE [dbo].[MemberNodeRoleMap] CHECK CONSTRAINT [FK_MemberNodeRoleMap_Roles]
GO
