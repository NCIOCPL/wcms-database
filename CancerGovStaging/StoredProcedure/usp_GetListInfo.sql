IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetListInfo]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetListInfo]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE usp_GetListInfo 
	(
	@ListId		uniqueidentifier
	)
AS
BEGIN
	SELECT List.ListId, 
		List.GroupId,
		List.ListName, 
		List.ListDesc, 
		List.ParentListId, 
		List.Priority,
		List.DescDisplay,
		List.ReleaseDateDisplay,
		List.ReleaseDateDisplayLoc,
		List.NCIViewId

	FROM List 
	WHERE List.ListId = @ListId
END

GO
GRANT EXECUTE ON [dbo].[usp_GetListInfo] TO [websiteuser_role]
GO
