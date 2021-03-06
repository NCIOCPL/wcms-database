SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Role]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Role](
	[RoleID] [bigint] IDENTITY(1,1) NOT NULL,
	[RoleName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateDate] [datetime] NULL CONSTRAINT [DF_Role_CreateDate]  DEFAULT (getdate()),
	[CreateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Role_CreateUserID]  DEFAULT (suser_sname()),
	[UpdateDate] [datetime] NULL CONSTRAINT [DF_Role_UpdateDate]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Role_UpdateUserID]  DEFAULT (suser_sname()),
	[Permission] [int] NULL,
 CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED 
(
	[RoleID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
