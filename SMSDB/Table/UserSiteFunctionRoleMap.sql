SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserSiteFunctionRoleMap]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[UserSiteFunctionRoleMap](
	[FunctionRoleID] [int] NOT NULL,
	[UserID] [uniqueidentifier] NOT NULL,
	[CreateDate] [datetime] NULL CONSTRAINT [DF_UserSiteFunctionRoleMap_CreateDate]  DEFAULT (getdate()),
	[CreateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_UserSiteFunctionRoleMap] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC,
	[FunctionRoleID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_UserSiteFunctionRoleMap_SiteFunctionRole]') AND parent_object_id = OBJECT_ID(N'[dbo].[UserSiteFunctionRoleMap]'))
ALTER TABLE [dbo].[UserSiteFunctionRoleMap]  WITH CHECK ADD  CONSTRAINT [FK_UserSiteFunctionRoleMap_SiteFunctionRole] FOREIGN KEY([FunctionRoleID])
REFERENCES [SiteFunctionRole] ([FunctionRoleID])
GO
ALTER TABLE [dbo].[UserSiteFunctionRoleMap] CHECK CONSTRAINT [FK_UserSiteFunctionRoleMap_SiteFunctionRole]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_UserSiteFunctionRoleMap_User]') AND parent_object_id = OBJECT_ID(N'[dbo].[UserSiteFunctionRoleMap]'))
ALTER TABLE [dbo].[UserSiteFunctionRoleMap]  WITH CHECK ADD  CONSTRAINT [FK_UserSiteFunctionRoleMap_User] FOREIGN KEY([UserID])
REFERENCES [User] ([UserID])
GO
ALTER TABLE [dbo].[UserSiteFunctionRoleMap] CHECK CONSTRAINT [FK_UserSiteFunctionRoleMap_User]
GO
