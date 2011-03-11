IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetSummarySection]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetSummarySection]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.usp_GetSummarySection    Script Date: 5/11/2004 5:50:31 PM ******/
/*

	4/14/2004	Chen Ling	Script created
*/

CREATE PROCEDURE dbo.usp_GetSummarySection
	(
		@SummaryGUID uniqueidentifier = null,
		@SummaryID	int = null,
		@SummarySectionID uniqueidentifier = null,
		@SectionID nvarchar(50) = null
	)

AS

BEGIN
	IF (@SummarySectionID <> null)
		BEGIN
			SELECT SummarySectionID, SummaryGUID, SummaryID, SectionID, SectionTitle, SectionType, Priority, SectionLevel, ParentSummarySectionID, TOC, [HTML], dbo.udf_GetDateLastModified(SummaryID) AS DateLastModified, dbo.udf_GetSummaryTopLevelSectionID(SummarySectionID) AS TopLevelSummarySectionID
			FROM SummarySection
			WHERE SummarySectionID = @SummarySectionID	
		END
	ELSE
		BEGIN
			IF (@SummaryID <> null)
				BEGIN
					SELECT SummarySectionID, SummaryGUID, SummaryID, SectionID, SectionTitle, SectionType, Priority, SectionLevel, ParentSummarySectionID, TOC, [HTML], dbo.udf_GetDateLastModified(SummaryID) AS DateLastModified, dbo.udf_GetSummaryTopLevelSectionID(SummarySectionID) AS TopLevelSummarySectionID
					FROM SummarySection
					WHERE SummaryID = @SummaryID	
					AND SectionID = @SectionID
				END
			ELSE
				BEGIN
					SELECT SummarySectionID, SummaryGUID, SummaryID, SectionID, SectionTitle, SectionType, Priority, SectionLevel, ParentSummarySectionID, TOC, [HTML], dbo.udf_GetDateLastModified(SummaryID) AS DateLastModified, dbo.udf_GetSummaryTopLevelSectionID(SummarySectionID) AS TopLevelSummarySectionID
					FROM SummarySection
					WHERE SummaryGUID = @SummaryGUID	
					AND SectionID = @SectionID
				END
		END
END
GO
GRANT EXECUTE ON [dbo].[usp_GetSummarySection] TO [websiteuser_role]
GO
