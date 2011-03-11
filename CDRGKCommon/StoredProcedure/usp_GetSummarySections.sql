IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetSummarySections]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetSummarySections]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.usp_GetSummarySections    Script Date: 5/11/2004 5:51:08 PM ******/
/*

	4/14/2004	Chen Ling	Script created
*/

CREATE PROCEDURE dbo.usp_GetSummarySections
	(
		@SummaryGUID 		uniqueidentifier = null,
		@SummaryID			int = null,
		@ParentSummarySectionID	uniqueidentifier = null
	)

AS

BEGIN

	IF (@SummaryID <> null)
		BEGIN
			SELECT SummarySectionID, SummaryGUID, SummaryID, SectionID, SectionTitle, SectionType, Priority, SectionLevel, ParentSummarySectionID, TOC, [HTML], dbo.udf_GetDateLastModified(SummaryID) AS DateLastModified
			FROM SummarySection
			WHERE SummaryID = @SummaryID AND ParentSummarySectionID = @ParentSummarySectionID
			ORDER BY Priority
		END
	ELSE
		BEGIN
			SELECT SummarySectionID, SummaryGUID, SummaryID, SectionID, SectionTitle, SectionType, Priority, SectionLevel, ParentSummarySectionID, TOC, [HTML], dbo.udf_GetDateLastModified(SummaryID) AS DateLastModified
			FROM SummarySection
			WHERE SummaryGUID = @SummaryGUID AND ParentSummarySectionID = @ParentSummarySectionID
			ORDER BY Priority
		END

END
GO
GRANT EXECUTE ON [dbo].[usp_GetSummarySections] TO [websiteuser_role]
GO
