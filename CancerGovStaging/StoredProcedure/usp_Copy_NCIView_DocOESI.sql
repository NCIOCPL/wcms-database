IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_Copy_NCIView_DocOESI]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_Copy_NCIView_DocOESI]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/**********************************************************************************

	Object's name:	usp_Copy_NCIView_DocOESI
	Object's type:	store proc
	Purpose:	Delete value from NCIView
	Author:		1/15/2002	Jhe	For admin side Script
			10/25/2004	Lijia	Remove OLDURL,HTMLAddendum and add ReviewedDate, ChangeComments

**********************************************************************************/
CREATE PROCEDURE dbo.usp_Copy_NCIView_DocOESI (
	@viewID uniqueidentifier,
	@newViewID uniqueidentifier OUTPUT
)
AS
BEGIN
	SET @newViewID = newid()
	
	BEGIN TRANSACTION
	
	INSERT INTO NCIView (
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
	SELECT @newViewID, 
			NCITemplateID,
			NCISectionID,
			GroupID,
			'Copy of ' + Title,
			ShortTitle,
			[Description],
			URL,
			'viewid=' + cast(@newViewID as varchar),
			MetaTitle,
			MetaDescription,
			MetaKeyword,
			CreateDate,
			ReleaseDate,
			ExpirationDate,
			Version,
			'EDIT',
			0,
			IsMultiSourced,
			IsLinkExternal,
			SpiderDepth,
			UpdateDate,
			UpdateUserID,
			PostedDate,
			DisplayDateMode,
			ReviewedDate,
			ChangeComments
	FROM NCIView
	WHERE NCIViewID = @viewID
	
	INSERT INTO ViewProperty (
			ViewPropertyID,
			NCIViewID,
			PropertyName,
			PropertyValue,
			UpdateDate,
			UpdateUserID
	)
	SELECT newid(),
			@newViewID,
			PropertyName,
			PropertyValue,
			UpdateDate,
			UpdateUserID
	FROM ViewProperty
	WHERE NCIViewID = @viewID
	
	CREATE TABLE #tmpTbl_MapID (
			OldNCIViewObjectID	uniqueidentifier,
			NewNCIViewObjectID	uniqueidentifier,
			OldDocumentID	uniqueidentifier,
			NewDocumentID	uniqueidentifier
	)
	
	INSERT INTO #tmpTbl_MapID (
			OldNCIViewObjectID,
			NewNCIViewObjectID,
			OldDocumentID,
			NewDocumentID
	)
	SELECT NCIViewObjectID, newid(), ObjectID, newid()
	FROM ViewObjects
	WHERE NCIViewID = @viewID
	
	INSERT INTO ViewObjects (
			NCIViewObjectID,
			NCIViewID,
			ObjectID,
			Type,
			Priority,
			UpdateDate,
			UpdateUserID
	)
	SELECT tmpMap.NewNCIViewObjectID,
			@newViewID,
			tmpMap.NewDocumentID,
			vo.Type,
			vo.Priority,
			vo.UpdateDate,
			vo.UpdateUserID
	FROM ViewObjects vo, #tmpTbl_MapID tmpMap
	WHERE vo.NCIViewObjectID = tmpMap.OldNCIViewObjectID
	
	
	INSERT INTO ViewObjectProperty (
			NCIViewObjectID,
			PropertyName,
			PropertyValue,
			UpdateDate,
			UpdateUserID
	)
	SELECT tmpMap.NewNCIViewObjectID,
			PropertyName,
			PropertyValue,
			UpdateDate,
			UpdateUserID
	FROM ViewObjectProperty vop, #tmpTbl_MapID tmpMap
	WHERE vop.NCIViewObjectID = tmpMap.OldNCIViewObjectID
	
	
	INSERT INTO Document (
			DocumentID,
			Title,
			ShortTitle,
			[Description],
			GroupID,
			DataType,
			DataSize,
			IsWirelessPage,
			TOC,
			Data,
			RunTimeOwnerID,
			CreateDate,
			ReleaseDate,
			ExpirationDate,
			UpdateDate,
			UpdateUserID
	)
	SELECT tmpMap.NewDocumentID,
			Title,
			ShortTitle,
			[Description],
			GroupID,
			DataType,
			DataSize,
			IsWirelessPage,
			TOC,
			Data,
			RunTimeOwnerID,
			CreateDate,
			ReleaseDate,
			ExpirationDate,
			UpdateDate,
			UpdateUserID
	FROM Document d, #tmpTbl_MapID tmpMap
	WHERE d.DocumentID = tmpMap.OldDocumentID
	
	INSERT INTO DocPart (
			DocPartID,
			DocumentID,
			Priority,
			Heading,
			Content,
			ShowTitleOrNot,
			UpdateUserID,
			UpdateDate
	)
	SELECT newid(),
			tmpMap.NewDocumentID,
			Priority,
			Heading,
			Content,
			ShowTitleOrNot,
			UpdateUserID,
			UpdateDate
	FROM DocPart dp, #tmpTbl_MapID tmpMap
	WHERE dp.DocumentID = tmpMap.OldDocumentID
	
	DROP TABLE #tmpTbl_MapID
	
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRANSACTION
		RETURN @@ERROR
	END
	
	COMMIT TRANSACTION
	
	SELECT @newViewID

END

GO
