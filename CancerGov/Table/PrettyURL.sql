SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PrettyURL]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[PrettyURL](
	[PrettyURLID] [uniqueidentifier] NOT NULL DEFAULT (newid()),
	[NCIViewID] [uniqueidentifier] NOT NULL,
	[DirectoryID] [uniqueidentifier] NOT NULL,
	[ObjectID] [uniqueidentifier] NULL,
	[RealURL] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CurrentURL] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsNew] [bit] NULL DEFAULT (0),
	[UpdateRedirectOrNot] [bit] NULL DEFAULT (0),
	[IsPrimary] [bit] NULL DEFAULT (0),
	[CreateDate] [datetime] NULL DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL DEFAULT (user_name()),
	[UpdateDate] [datetime] NULL DEFAULT (getdate()),
	[IsRoot] [bit] NULL DEFAULT (0),
UNIQUE NONCLUSTERED 
(
	[CurrentURL] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[PrettyURL]') AND name = N'IX_prettyURL_NCIViewIDObjectid')
CREATE CLUSTERED INDEX [IX_prettyURL_NCIViewIDObjectid] ON [dbo].[PrettyURL] 
(
	[NCIViewID] ASC,
	[ObjectID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
GRANT SELECT ON [dbo].[PrettyURL] TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] TO [prettyurluser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([PrettyURLID]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([PrettyURLID]) TO [prettyurluser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([PrettyURLID]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([NCIViewID]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([NCIViewID]) TO [prettyurluser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([NCIViewID]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([DirectoryID]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([DirectoryID]) TO [prettyurluser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([DirectoryID]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([ObjectID]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([ObjectID]) TO [prettyurluser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([ObjectID]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([RealURL]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([RealURL]) TO [prettyurluser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([RealURL]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([CurrentURL]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([CurrentURL]) TO [prettyurluser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([CurrentURL]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([IsNew]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([IsNew]) TO [prettyurluser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([IsNew]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([UpdateRedirectOrNot]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([UpdateRedirectOrNot]) TO [prettyurluser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([UpdateRedirectOrNot]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([IsPrimary]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([IsPrimary]) TO [prettyurluser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([IsPrimary]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([CreateDate]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([CreateDate]) TO [prettyurluser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([CreateDate]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([UpdateUserID]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([UpdateUserID]) TO [prettyurluser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([UpdateUserID]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([UpdateDate]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([UpdateDate]) TO [prettyurluser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([UpdateDate]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([IsRoot]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([IsRoot]) TO [prettyurluser_role]
GO
GRANT SELECT ON [dbo].[PrettyURL] ([IsRoot]) TO [websiteuser_role]
GO
