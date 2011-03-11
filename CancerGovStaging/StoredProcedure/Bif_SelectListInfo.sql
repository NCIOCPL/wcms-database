IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Bif_SelectListInfo]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[Bif_SelectListInfo]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE dbo.Bif_SelectListInfo
(
	@ListID as uniqueidentifier
)
AS
	SET NOCOUNT ON;
SELECT List.ListID, 
	List.ListName, 
	List.ListDesc, 
	List.DescDisplay,
	NCIView.Title, 
	NCIView.Description
	
FROM List 
	INNER JOIN ListItem 
		ON List.ListID = ListItem.ListID 
	INNER JOIN NCIView 
		ON ListItem.NCIViewID = NCIView.NCIViewID 
WHERE (List.ListID = @ListID)

GO
GRANT EXECUTE ON [dbo].[Bif_SelectListInfo] TO [websiteuser_role]
GO
