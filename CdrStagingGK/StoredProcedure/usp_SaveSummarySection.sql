IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveSummarySection]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveSummarySection]
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

*	To Do List:
*
*/
CREATE PROCEDURE dbo.usp_SaveSummarySection
	(
		@SummarySectionID	uniqueidentifier,
		@SummaryGUID	uniqueidentifier,
		@SummaryID		int,
		@SectionID		nvarchar(50),
		@SectionType		varchar(20),
		@SectionTitle		nvarchar(250),
		@Priority		int,
		@SectionLevel		int,
		@ParentSummarySectionID	uniqueidentifier,
		@HTML		ntext,
		@TOC		nvarchar(4000),
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	

	INSERT INTO SummarySection (
		SummarySectionID, 
		SummaryGUID, 
		SummaryID, 
		SectionID, 
		SectionType,
		SectionTitle, 
		Priority, 
		SectionLevel, 
		ParentSummarySectionID, 
		TOC,
		[HTML]
	)
	VALUES (
		@SummarySectionID,
		@SummaryGUID,
		@SummaryID,
		@SectionID,
		@SectionType,
		@SectionTitle,
		@Priority,
		@SectionLevel,
		@ParentSummarySectionID,
		@TOC,
		@HTML
	)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @SummaryID,'SummarySection')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.Summary table Saved for ID: '+ convert(varchar(50), @SummaryID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveSummarySection] TO [Gatekeeper_role]
GO
