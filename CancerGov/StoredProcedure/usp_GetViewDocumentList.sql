IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetViewDocumentList]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetViewDocumentList]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE usp_GetViewDocumentList
	(
	@ViewId	uniqueidentifier
	)
AS
BEGIN
	SELECT vo.Priority, d.DocumentId, dbo.udf_GetViewObjectPrettyUrl(v.NCIViewId, d.DocumentId) AS PrettyUrl, d.Title, d.ShortTitle, d.Description, d.Data, d.TOC
	FROM NCIView v LEFT OUTER JOIN (ViewObjects vo INNER JOIN Document d ON vo.ObjectId = d.DocumentId)ON v.NCIViewId = vo.NCIViewId
	WHERE vo.Type = 'DOCUMENT' AND v.NCIViewId = @ViewId
	ORDER BY vo.Priority ASC
END
GO
GRANT EXECUTE ON [dbo].[usp_GetViewDocumentList] TO [websiteuser_role]
GO
