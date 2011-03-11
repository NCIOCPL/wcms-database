IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetViewObjects]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetViewObjects]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*	NCI - National Cancer Institute
*	
*	Purpose:	
*
*	Objects Used:
*
*	Change History:
*
*	To Do List:
*
*/

CREATE PROCEDURE usp_GetViewObjects
	(
	@ViewId	uniqueidentifier,
	@Type		varchar(40) = null
	)
AS
BEGIN

	IF NULLIF(@Type, '') IS NULL
	BEGIN
		SELECT vo.NCIViewId, 
			vo.ObjectId, 
			vo.Type,
			vo.Priority,
			vo.NCIViewObjectID,
			dbo.udf_GetViewObjectPrettyUrl(vo.NCIViewId, vo.ObjectId) AS PrettyUrl
		FROM 	ViewObjects vo 
		WHERE vo.NCIViewId = @ViewId
		ORDER BY vo.Priority
	END
	ELSE
	BEGIN
		SELECT vo.NCIViewId, 
			vo.ObjectId, 
			vo.Type,
			vo.Priority,
			vo.NCIViewObjectID,
			dbo.udf_GetViewObjectPrettyUrl(vo.NCIViewId, vo.ObjectId) AS PrettyUrl
		FROM 	ViewObjects vo 
		WHERE vo.NCIViewId = @ViewId AND vo.Type = @Type
		ORDER BY vo.Priority
	END
END

GO
GRANT EXECUTE ON [dbo].[usp_GetViewObjects] TO [websiteuser_role]
GO
