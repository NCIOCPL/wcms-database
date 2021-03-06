SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[organizationname]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[organizationname](
	[OrganizationID] [int] NOT NULL,
	[Name] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Type] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[organizationname]') AND name = N'CI_OrganizationName')
CREATE CLUSTERED INDEX [CI_OrganizationName] ON [dbo].[organizationname] 
(
	[OrganizationID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
