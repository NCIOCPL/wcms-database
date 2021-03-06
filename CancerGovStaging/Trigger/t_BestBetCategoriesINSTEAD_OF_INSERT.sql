਍ഀ
/****** Object:  Trigger [t_BestBetCategoriesINSTEAD_OF_INSERT]    Script Date: 01/09/2008 11:49:22 ******/਍ഀ
IF   OBJECT_ID(N'[dbo].[t_BestBetCategoriesINSTEAD_OF_INSERT]') is not null਍ഀ
DROP TRIGGER [dbo].[t_BestBetCategoriesINSTEAD_OF_INSERT]਍ഀ
GO਍ഀ
/****** Object:  Trigger [dbo].[t_BestBetCategoriesINSTEAD_OF_INSERT]    Script Date: 01/09/2008 11:49:12 ******/਍ഀ
SET ANSI_NULLS ON਍ഀ
GO਍ഀ
SET QUOTED_IDENTIFIER ON਍ഀ
GO਍ഀ
/**********************************************************************************਍ഀ
਍ഀ
	Object's name:	t_BestBetCategoriesINSTEAD_OF_INSERT਍ഀ
	Object's type:	trigger਍ഀ
	Purpose:	Update value to AuditBestBetCategories਍ഀ
	Change History:	11/04/2004	Lijia add ChangeComments਍ഀ
਍ഀ
**********************************************************************************/਍ഀ
CREATE TRIGGER  [dbo].[t_BestBetCategoriesINSTEAD_OF_INSERT] ON [dbo].[BestBetCategories] ਍ഀ
INSTEAD OF INSERT਍ഀ
AS਍ഀ
BEGIN਍ഀ
	INSERT INTO BestBetCategories (਍ഀ
		CategoryID,਍ഀ
		CatName,਍ഀ
		CatProfile,਍ഀ
		ListID,਍ഀ
		Weight,਍ഀ
		UpdateDate,਍ഀ
		UpdateUserID,਍ഀ
		Status,਍ഀ
		IsSpanish,਍ഀ
		IsOnProduction,਍ഀ
		ChangeComments,਍ഀ
		isExactMatch )		਍ഀ
	SELECT ਍ഀ
		ins.CategoryID,਍ഀ
		ins.CatName,਍ഀ
		ins.CatProfile,਍ഀ
		ins.ListID,਍ഀ
		ins.Weight,਍ഀ
		ins.UpdateDate,਍ഀ
		ins.UpdateUserID,਍ഀ
		ins.Status,਍ഀ
		ins.IsSpanish,਍ഀ
		ins.IsOnProduction,਍ഀ
		ins.ChangeComments ,਍ഀ
		ins.isExactMatch ਍ഀ
	FROM 	inserted ins਍ഀ
਍ഀ
਍ഀ
	--Then we log information in to the DocumentAudit table਍ഀ
	INSERT INTO AuditBestBetCategories (਍ഀ
		AuditActionType,਍ഀ
		CategoryID,਍ഀ
		CatName,਍ഀ
		CatProfile,਍ഀ
		ListID,਍ഀ
		Weight,਍ഀ
		UpdateDate,਍ഀ
		UpdateUserID,਍ഀ
		Status,਍ഀ
		IsSpanish, ਍ഀ
		IsOnProduction,਍ഀ
		ChangeComments,਍ഀ
		isExactMatch  )	਍ഀ
	SELECT ਍ഀ
		'INSERT' as AuditActionType,਍ഀ
		ins.CategoryID,਍ഀ
		ins.CatName,਍ഀ
		ins.CatProfile,਍ഀ
		ins.ListID,਍ഀ
		ins.Weight,਍ഀ
		ins.UpdateDate,਍ഀ
		ins.UpdateUserID,਍ഀ
		ins.Status,਍ഀ
		ins.IsSpanish,਍ഀ
		ins.IsOnProduction,਍ഀ
		ins.ChangeComments ,਍ഀ
		ins.isExactMatch ਍ഀ
	FROM 	inserted ins਍ഀ
END਍ഀ
਍ഀ
਍ഀ
