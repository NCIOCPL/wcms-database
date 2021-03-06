਍ഀ
਍ഀ
IF  OBJECT_ID(N'[dbo].[t_BestBetCategoriesINSTEAD_OF_UPDATE]') is not NULL਍ഀ
DROP TRIGGER [dbo].[t_BestBetCategoriesINSTEAD_OF_UPDATE]਍ഀ
GO਍ഀ
/****** Object:  Trigger [dbo].[t_BestBetCategoriesINSTEAD_OF_UPDATE]    Script Date: 01/09/2008 14:27:57 ******/਍ഀ
SET ANSI_NULLS ON਍ഀ
GO਍ഀ
SET QUOTED_IDENTIFIER ON਍ഀ
GO਍ഀ
਍ഀ
/**********************************************************************************਍ഀ
਍ഀ
	Object's name:	t_BestBetCategoriesINSTEAD_OF_UPDATE਍ഀ
	Object's type:	trigger਍ഀ
	Purpose:	Update value to AuditBestBetCategories਍ഀ
	Change History:	11/04/2004	Lijia add ChangeComments਍ഀ
਍ഀ
**********************************************************************************/਍ഀ
਍ഀ
CREATE TRIGGER  [dbo].[t_BestBetCategoriesINSTEAD_OF_UPDATE] ON [dbo].[BestBetCategories]਍ഀ
INSTEAD OF UPDATE਍ഀ
AS਍ഀ
BEGIN਍ഀ
	--First we update Original BestBetCategories਍ഀ
	UPDATE Original਍ഀ
	SET 	CategoryID 	= New.CategoryID,਍ഀ
		CatName	= New.CatName,਍ഀ
		CatProfile	= New.CatProfile,਍ഀ
		ListID		= New.ListID,਍ഀ
		Weight		= New.Weight,਍ഀ
		UpdateDate	= New.UpdateDate,਍ഀ
		UpdateUserID	= New.UpdateUserID,਍ഀ
		Status		= New.Status,਍ഀ
		IsOnProduction	= New.IsOnProduction,਍ഀ
		IsSpanish		= New.IsSpanish, ਍ഀ
		ChangeComments	= New.ChangeComments,਍ഀ
		IsExactMatch	= New.IsExactMatch਍ഀ
	FROM	BestBetCategories as Original, inserted as New 	਍ഀ
	WHERE 	Original.CategoryID = New.CategoryID ਍ഀ
਍ഀ
	--Then we log information in to the AuditBestBetCategories table਍ഀ
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
		IsSpanish,਍ഀ
		IsOnProduction,਍ഀ
		ChangeComments,਍ഀ
		isExactMatch)	਍ഀ
	SELECT ਍ഀ
		'UPDATE' as AuditActionType,਍ഀ
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
		ins.ChangeComments,਍ഀ
		ins.isExactMatch਍ഀ
	FROM 	inserted ins਍ഀ
END਍ഀ
਍ഀ
਍ഀ
਍ഀ
਍ഀ
਍ഀ
਍ഀ
਍ഀ
