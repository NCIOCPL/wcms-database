SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[RedirectMap]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[RedirectMap](
	[map_id] [uniqueidentifier] NOT NULL CONSTRAINT [DF_RedirectMap_map_id]  DEFAULT (newid()),
	[OldURL] [varchar](512) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CurrentURL] [varchar](512) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Source] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[UpdateDate] [datetime] NULL,
	[HitNum] [int] NOT NULL CONSTRAINT [DF_RedirectMap_Hitnum]  DEFAULT (0)
) ON [PRIMARY]
END
GO
GRANT SELECT ON [dbo].[RedirectMap] TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[RedirectMap] TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[RedirectMap] ([map_id]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[RedirectMap] ([map_id]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[RedirectMap] ([OldURL]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[RedirectMap] ([OldURL]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[RedirectMap] ([CurrentURL]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[RedirectMap] ([CurrentURL]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[RedirectMap] ([Source]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[RedirectMap] ([Source]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[RedirectMap] ([UpdateDate]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[RedirectMap] ([UpdateDate]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[RedirectMap] ([HitNum]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[RedirectMap] ([HitNum]) TO [websiteuser_role]
GO
