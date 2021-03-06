SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Permissions]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[Permissions](
	[permissionID] [int] IDENTITY(150,1) NOT NULL,
	[permissionName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[permssionDescription] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[creationDate] [datetime] NOT NULL CONSTRAINT [DF_Permissions_creationDate]  DEFAULT (getdate()),
	[creationUser] [uniqueidentifier] NULL,
	[UpdateDate] [datetime] NOT NULL CONSTRAINT [DF_Permissions_UpdateDate]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Permissions_UpdateUserID]  DEFAULT (user_name()),
 CONSTRAINT [PK_GroupPermissions] PRIMARY KEY CLUSTERED 
(
	[permissionID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO
