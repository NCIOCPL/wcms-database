IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetMultiPageTOC]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetMultiPageTOC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--***********************************************************************
-- Create New Object 
--************************************************************************




CREATE PROCEDURE dbo.usp_GetMultiPageTOC
	(
	@ViewId	uniqueidentifier
	)
AS
BEGIN

	SELECT 
		vo.NCIViewObjectID,
		vo.ObjectID,
		d.ShortTitle,
		d.Title,
		d.Description,
		d.TOC,
		dbo.udf_GetViewObjectPrettyUrl(vo.NCIViewId, vo.ObjectId) AS PrettyUrl

	FROM 	ViewObjects vo INNER JOIN Document d on vo.ObjectId = d.DocumentId		

	WHERE
		vo.NCIViewId = @ViewId AND Type = 'DOCUMENT'
		AND vo.nciviewobjectid not in
		(
			SELECT
				 nciviewobjectid 
			FROM	 viewobjectproperty vop 
			WHERE	
				 vop.propertyname='IsSubDocument' AND vop.propertyValue='true'
		)

	ORDER BY vo.Priority

END

GO
GRANT EXECUTE ON [dbo].[usp_GetMultiPageTOC] TO [websiteuser_role]
GO
