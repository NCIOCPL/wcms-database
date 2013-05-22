IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_NCIView_INSTEAD_OF_UPDATE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	UPDATE Original
	SET	Original.NCITemplateID = New.NCITemplateID,
		Original.NCISectionID = New.NCISectionID, 
		Original.GroupID = New.GroupID,
		Original.Title = New.Title,
		Original.ShortTitle = New.ShortTitle,
		Original.[Description] = New.[Description],
		Original.URL = New.URL,
		Original.URLArguments = New.URLArguments,
		Original.MetaTitle = New.MetaTitle,
		Original.MetaDescription = New.MetaDescription,
		Original.MetaKeyword = New.MetaKeyword,
		Original.CreateDate = New.CreateDate,
		Original.ReleaseDate = New.ReleaseDate,
		Original.ExpirationDate = New.ExpirationDate,
		Original.Version = [dbo].[GetNextSubVersion] (New.Version),
		Original.Status = New.Status,
		Original.IsOnProduction = New.IsOnProduction,
		Original.IsMultiSourced = New.IsMultiSourced,
		Original.IsLinkExternal = New.IsLinkExternal,
		Original.SpiderDepth = New.SpiderDepth,
		Original.UpdateDate = New.UpdateDate,
		Original.UpdateUserID = New.UpdateUserID,
		Original.PostedDate = New.PostedDate,
		Original.DisplayDateMode = New.DisplayDateMode,
		Original.ReviewedDate = New.ReviewedDate,
		Original.ChangeComments = New.ChangeComments
	FROM	NCIView as Original, 
		inserted as New 	
	WHERE  Original.NCIViewID = New.NCIViewID

	INSERT INTO AuditNCIView(AuditActionType, AuditActionDate, AuditActionUserID,
		NCIViewID,
		NCITemplateID,
		NCISectionID, 
		GroupID,
		Title,
		ShortTitle,
		[Description],
		URL,
		URLArguments,
		MetaTitle,
		MetaDescription,
		MetaKeyword,
		CreateDate,
		ReleaseDate,
		ExpirationDate,
		Version,
		Status,
		IsOnProduction,
		IsMultiSourced,
		IsLinkExternal,
		SpiderDepth,
		UpdateDate,
		UpdateUserID,
		PostedDate,
		DisplayDateMode,
		ReviewedDate,
		ChangeComments) 
	SELECT ''UPDATE'' AS AuditActionType,
		GETDATE() AS AuditActionDate, 
		USER_NAME() AS AuditActionUserID,
		tbl.NCIViewID,
		tbl.NCITemplateID,
		tbl.NCISectionID, 
		tbl.GroupID,
		tbl.Title,
		CASE 
			WHEN NULLIF(LTRIM(RTRIM(ISNULL(tbl.ShortTitle,''''))), '''') IS NULL THEN LEFT(LTRIM(RTRIM(tbl.Title)),47)+''...''
			ELSE tbl.ShortTitle
		END AS ShortTitle,
		tbl.[Description],
		tbl.URL,
		tbl.URLArguments,
		tbl.MetaTitle,
		tbl.MetaDescription,
		tbl.MetaKeyword,
		tbl.CreateDate,
		tbl.ReleaseDate,
		tbl.ExpirationDate,
		 [dbo].[GetNextSubVersion] (tbl.Version), -- GET NEXT Version --tbl.Version,
		tbl.Status,
		tbl.IsOnProduction,
		tbl.IsMultiSourced,
		tbl.IsLinkExternal,
		tbl.SpiderDepth,
		tbl.UpdateDate,
		tbl.UpdateUserID,
		tbl.PostedDate,
		tbl.DisplayDateMode,
		tbl.ReviewedDate,
		tbl.ChangeComments
	FROM 	inserted tbl
END







' 
GO
