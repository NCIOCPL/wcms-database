IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_PushExtractedDrugInfoSummaryData]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_PushExtractedDrugInfoSummaryData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*	NCI - National Cancer Institute
*	
*	Purpose:	
*	- Push Extracted data from CDRStagingGK to CDRPreviewGK	
*
*	Objects Used:
*
*	Change History:
*	To Do List:
*
*/
CREATE PROCEDURE dbo.usp_PushExtractedDrugInfoSummaryData
	(
	@DocumentID 	int,
	@UpdateUserID 	varchar(50),
	@CleanOldData	varchar(3) = 'YES' -- "yes" by default
	)
AS
BEGIN

	--**************************************************************************************************************
	DECLARE @UpdateDate datetime, @r int

	--**************************************************************************************************************
	SELECT 	@UpdateDate = GETDATE()	

	
	
	PRINT  '           STARTED - Push data to DrugInfoSummary  '

	IF @CleanOldData = 'Yes' 
	BEGIN
		EXEC  @r = CDRPreviewGK.dbo.usp_ClearExtractedDrugInfoSummaryData @DocumentID, 'No' -- "NO" means do not Clear Document Properties
		IF (@@ERROR <> 0) or (@r <>0)
		BEGIN
	
			RAISERROR ( 70001, 16, 1, @DocumentID, 'DrugInfoSummary')
			RETURN 70001
		END 
	END

	--**************************************************************************************************************
	PRINT  '           Push dbo.DrugInfoSummary table '
	-- dbo.DrugInfo

	INSERT INTO CDRPreviewGK.dbo.DrugInfoSummary
		(
		DrugInfoSummaryID,
		Title,
		Description,
		PrettyURL,
		DateFirstPublished,
		DateLastModified,
		TerminologyLink,
		NCIViewID,
		UpdateDate,
		UpdateUserID
		)
	SELECT 	DrugInfoSummaryID,
		Title,
		Description,
		PrettyURL,
		DateFirstPublished,
		DateLastModified,
		TerminologyLink,
		NCIViewID,
		@UpdateDate,
		@UpdateUserID
	FROM 	CDRStagingGK.dbo.DrugInfoSummary
	WHERE 	DrugInfoSummaryID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		--!!! See usp_ResetAllCDRErrorMessages for more details
		RAISERROR ( 70000, 16, 1, @DocumentID, 'dbo.DrugInfoSummary')
		RETURN 70000
	END 	

	PRINT  '           DONE - Push data to DrugInfoSummary and related tables from staging to Preview '

	RETURN 0

END


GO
GRANT EXECUTE ON [dbo].[usp_PushExtractedDrugInfoSummaryData] TO [Gatekeeper_role]
GO
