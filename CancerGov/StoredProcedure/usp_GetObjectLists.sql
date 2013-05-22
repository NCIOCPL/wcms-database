IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetObjectLists]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetObjectLists]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE dbo.usp_GetObjectLists
	(
	@ObjectID	uniqueidentifier
	)
AS
BEGIN
	SELECT 
		ListId, 
		ListName, 
		ListDesc, 
		ParentListId, 
		Priority, 
		ReleaseDateDisplay,
		ReleaseDateDisplayLoc, 
		dbo.udf_GetViewObjectProperty(ListId, 'ShowListDescription') AS ShowListDescription
	FROM 	List
	WHERE parentlistid = 
		(select PropertyValue 
			from ViewObjectProperty vop, ViewObjects vo
			where vo.ObjectID=@ObjectID
			AND vo.NCIViewObjectID=vop.NCIViewObjectID
			AND PropertyName = 'DigestRelatedListID'
		)
	ORDER BY Priority ASC
END
GO
GRANT EXECUTE ON [dbo].[usp_GetObjectLists] TO [websiteuser_role]
GO
