SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[OrganizationRole]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[OrganizationRole](
	[OrganizationRoleID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_OrganizationRole_OrganizationRoleID]  DEFAULT (newid()),
	[Type] [uniqueidentifier] NULL,
	[Name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ShortName] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NOT NULL CONSTRAINT [DF_OrganizationRole_UpdateDate]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrganizationRole_UpdateUserID]  DEFAULT (user_name()),
	[SourceID] [numeric](18, 0) NULL,
	[DataSource] [char](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_OrganizationRole] PRIMARY KEY NONCLUSTERED 
(
	[OrganizationRoleID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[OrganizationRole]') AND name = N'IX_OrgRole_SourceID_DataSource')
CREATE NONCLUSTERED INDEX [IX_OrgRole_SourceID_DataSource] ON [dbo].[OrganizationRole] 
(
	[SourceID] ASC,
	[DataSource] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_OrganizationRole_Type]') AND type = 'F')
ALTER TABLE [dbo].[OrganizationRole]  WITH CHECK ADD  CONSTRAINT [FK_OrganizationRole_Type] FOREIGN KEY([Type])
REFERENCES [Type] ([TypeID])
GO
ALTER TABLE [dbo].[OrganizationRole] CHECK CONSTRAINT [FK_OrganizationRole_Type]
GO
