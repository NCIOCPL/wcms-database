IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetDocuments]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetDocuments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.usp_GetDocuments 

@ViewId	uniqueidentifier

AS
BEGIN
SELECT d.*
FROM Document d INNER JOIN ViewObjects vo ON d.DocumentID = vo.ObjectID
WHERE vo.NCIViewId = @ViewId AND UPPER(LTRIM(RTRIM(vo.Type))) = 'DOCUMENT'
ORDER BY vo.Priority
END

GO
GRANT EXECUTE ON [dbo].[usp_GetDocuments] TO [websiteuser]
GO
GRANT EXECUTE ON [dbo].[usp_GetDocuments] TO [websiteuser_role]
GO
