IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DocumentManager_DocumentPrettyUrl_GetAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[DocumentManager_DocumentPrettyUrl_GetAll]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].DocumentManager_DocumentPrettyUrl_GetAll
AS
BEGIN
	SELECT
		DocumentPrettyUrlID,
		DocumentID,
		PrettyUrl,
		RealUrl,
		IsPrimary
	FROM DocumentPrettyUrl

END

GO
GRANT EXECUTE ON [dbo].[DocumentManager_DocumentPrettyUrl_GetAll] TO [websiteuser_role]
GO
