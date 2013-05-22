IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_NCIView_INSTEAD_OF_INSERT]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO NCIView(
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
		ChangeComments
		) 
	SELECT 	
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

	INSERT INTO AuditNCIView(AuditActionType,
		AuditActionDate, 
		AuditActionUserID,
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
	SELECT ''INSERT'' as AuditActionType,
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
