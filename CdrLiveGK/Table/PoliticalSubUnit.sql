SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PoliticalSubUnit]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[PoliticalSubUnit](
	[PoliticalSubUnitID] [int] NOT NULL,
	[FullName] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ShortName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CountryName] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CountryID] [int] NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_PoliticalSubUnit] PRIMARY KEY CLUSTERED 
(
	[PoliticalSubUnitID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO
GRANT SELECT ON [dbo].[PoliticalSubUnit] TO [Gatekeeper_role]
GO
GRANT SELECT ON [dbo].[PoliticalSubUnit] TO [webSiteUser_role]
GO
GRANT SELECT ON [dbo].[PoliticalSubUnit] ([PoliticalSubUnitID]) TO [Gatekeeper_role]
GO
GRANT SELECT ON [dbo].[PoliticalSubUnit] ([PoliticalSubUnitID]) TO [webSiteUser_role]
GO
GRANT SELECT ON [dbo].[PoliticalSubUnit] ([FullName]) TO [Gatekeeper_role]
GO
GRANT SELECT ON [dbo].[PoliticalSubUnit] ([FullName]) TO [webSiteUser_role]
GO
GRANT SELECT ON [dbo].[PoliticalSubUnit] ([ShortName]) TO [Gatekeeper_role]
GO
GRANT SELECT ON [dbo].[PoliticalSubUnit] ([ShortName]) TO [webSiteUser_role]
GO
GRANT SELECT ON [dbo].[PoliticalSubUnit] ([CountryName]) TO [Gatekeeper_role]
GO
GRANT SELECT ON [dbo].[PoliticalSubUnit] ([CountryName]) TO [webSiteUser_role]
GO
GRANT SELECT ON [dbo].[PoliticalSubUnit] ([CountryID]) TO [Gatekeeper_role]
GO
GRANT SELECT ON [dbo].[PoliticalSubUnit] ([CountryID]) TO [webSiteUser_role]
GO
GRANT SELECT ON [dbo].[PoliticalSubUnit] ([UpdateDate]) TO [Gatekeeper_role]
GO
GRANT SELECT ON [dbo].[PoliticalSubUnit] ([UpdateDate]) TO [webSiteUser_role]
GO
GRANT SELECT ON [dbo].[PoliticalSubUnit] ([UpdateUserID]) TO [Gatekeeper_role]
GO
GRANT SELECT ON [dbo].[PoliticalSubUnit] ([UpdateUserID]) TO [webSiteUser_role]
GO
