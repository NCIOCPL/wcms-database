IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetListChildren]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetListChildren]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--***********************************************************************
-- Create New Object 
--************************************************************************

CREATE PROCEDURE dbo.usp_GetListChildren

	@ListId	uniqueidentifier

AS

BEGIN
	SELECT List.ListId,
		List.GroupId,
		List.ListName, 
		List.ListDesc, 
		List.Url,
		List.ParentListID,
		List.NCIViewId,
		List.Priority,
		List.UpdateDate,
		List.UpdateUserId,
		List.DescDisplay,
		List.ReleaseDateDisplay,
		List.ReleaseDateDisplayLoc
	FROM List 
	WHERE List.ParentListId = @ListId 
	ORDER BY List.Priority ASC
END

GO
GRANT EXECUTE ON [dbo].[usp_GetListChildren] TO [websiteuser_role]
GO
