IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetSummarySectionsInfo]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetSummarySectionsInfo]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.usp_GetSummarySectionsInfo    Script Date: 5/11/2004 5:51:31 PM ******/
/*

	4/14/2004	Chen Ling	Script created
*/

CREATE PROCEDURE dbo.usp_GetSummarySectionsInfo
	(
		@SummaryGUID uniqueidentifier = null,
		@SummaryID	int = null
	)

AS

BEGIN

	IF (@SummaryID <> null)
		BEGIN
			SELECT SummarySectionID, SummaryGUID, SummaryID, SectionID, SectionTitle, Priority, SectionLevel, ParentSummarySectionID
			FROM SummarySection
			WHERE SummaryID = @SummaryID
			ORDER BY Priority
		END
	ELSE
		BEGIN
			SELECT SummarySectionID, SummaryGUID, SummaryID, SectionID, SectionTitle, Priority, SectionLevel, ParentSummarySectionID
			FROM SummarySection
			WHERE SummaryGUID = @SummaryGUID
			ORDER BY Priority
		END

END

GO
