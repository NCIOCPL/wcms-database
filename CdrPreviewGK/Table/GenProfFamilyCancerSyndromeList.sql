SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GenProfFamilyCancerSyndromeList]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[GenProfFamilyCancerSyndromeList](
	[FamilyCancerSyndromeListID] [int] NOT NULL,
	[FamilyCancerSyndrome] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
END
GO
GRANT SELECT ON [dbo].[GenProfFamilyCancerSyndromeList] TO [webSiteUser_role]
GO
GRANT SELECT ON [dbo].[GenProfFamilyCancerSyndromeList] ([FamilyCancerSyndromeListID]) TO [webSiteUser_role]
GO
GRANT SELECT ON [dbo].[GenProfFamilyCancerSyndromeList] ([FamilyCancerSyndrome]) TO [webSiteUser_role]
GO
GRANT SELECT ON [dbo].[GenProfFamilyCancerSyndromeList] ([UpdateDate]) TO [webSiteUser_role]
GO
GRANT SELECT ON [dbo].[GenProfFamilyCancerSyndromeList] ([UpdateUserID]) TO [webSiteUser_role]
GO
