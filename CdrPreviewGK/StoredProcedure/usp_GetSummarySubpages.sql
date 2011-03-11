SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].usp_GetSummarySubpages') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].usp_GetSummarySubpages
GO

CREATE  PROCEDURE [dbo].[usp_GetSummarySubpages]
AS
BEGIN
	BEGIN TRY
		
		SELECT SummaryGUID, summaryID, SectionID , Priority 
		FROM SummarySection 
		WHERE SectionLevel = 1 
		AND SectionType = 'SummarySection' 
		ORDER BY summaryID, Priority


		SELECT SummaryGUID, summaryID, SectionID , Priority 
		FROM SummarySection 
		WHERE SectionType = 'Table' 
		ORDER BY summaryID, Priority


	END TRY

	BEGIN CATCH
		RETURN 10805
	END CATCH 
END
GO

GRANT EXECUTE ON [dbo].usp_GetSummarySubpages TO websiteuser_role

GO

