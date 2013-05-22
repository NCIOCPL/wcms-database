SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].usp_GetAllCDRPrettyURLs') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].usp_GetAllCDRPrettyURLs
GO

CREATE  PROCEDURE [dbo].usp_GetAllCDRPrettyURLs
AS
BEGIN
	BEGIN TRY
		
		SELECT ObjectID, isnull(currenturl, proposedurl) as prettyURL, realurl
		FROM PrettyURL p, NCIView v 
		WHERE p.NCIViewID = v.NCIViewID 
		AND v.NCITemplateID = 'FFF2D734-6A7A-46F0-AF38-DA69C8749AD0' 
--		AND IsRoot = 0 
--		AND ObjectID IS NOT NULL


	END TRY

	BEGIN CATCH
		RETURN 10803
	END CATCH 
END
GO

GRANT EXECUTE ON [dbo].usp_GetAllCDRPrettyURLs TO websiteuser_role

GO

