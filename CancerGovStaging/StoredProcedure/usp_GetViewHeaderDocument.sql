IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetViewHeaderDocument]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetViewHeaderDocument]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE usp_GetViewHeaderDocument 
	(
	@ViewId	uniqueidentifier
	)

AS
	
	SELECT v.Title, d.Data
	FROM NCIView v LEFT OUTER JOIN (ViewObjects vo INNER JOIN Document d ON vo.ObjectId = d.DocumentId) ON v.NCIViewId = vo.NCIViewId LEFT OUTER JOIN NCISection s ON v.NCISectionId = s.NCISectionId
	WHERE v.NCIViewId = @ViewId AND vo.Type = 'HDRDOC'
GO
GRANT EXECUTE ON [dbo].[usp_GetViewHeaderDocument] TO [websiteuser_role]
GO
