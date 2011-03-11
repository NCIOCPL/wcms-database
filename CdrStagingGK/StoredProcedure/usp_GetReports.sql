IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetReports]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetReports]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vadim
-- Create date: 4/2/07
-- Description:	Get one of the several reports
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetReports] 
	@ReportNum int,
	@Status_Code int OUTPUT,
	@Status_Text	varchar(255) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	IF @ReportNum < 1 OR @ReportNum > 8
	BEGIN
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Error in usp_GetReports: Invalid parameter'
		RAISERROR('Error in usp_GetReports: Invalid parameter', 16, 1)
	END
	
	IF @ReportNum = 1  --1.Check Summary Load 
	BEGIN 
		SELECT 1 AS 'SortOrder', 'Summaries in Document Table' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.Document where DocumentTypeID = 6 ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.Document where DocumentTypeID = 6 ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.Document where DocumentTypeID = 6 ) AS 'On Staging' 
		UNION SELECT 2 AS 'SortOrder', 'Summary Table' AS 'Table', 
		( select count(*) from CDRLiveGK..Summary ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK..Summary ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK..Summary ) AS 'On Staging' 
		UNION SELECT 3 AS 'SortOrder', 'SummaryRelations Table' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.SummaryRelations ) AS 'On Live', 
		( select count(*) from CDRPreviewGK.dbo.SummaryRelations ) AS 'On Preview', 
		( select count(*) from CDRStagingGK.dbo.SummaryRelations ) AS 'On Staging' 
		UNION SELECT 4 AS 'SortOrder', 'SummarySection Table' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.SummarySection ) AS 'On Live', 
		( select count(*) from CDRPreviewGK.dbo.SummarySection ) AS 'On Preview', 
		( select count(*) from CDRStagingGK.dbo.SummarySection ) AS 'On Staging' 
		ORDER BY SortOrder
	END
	ELSE
		IF @ReportNum = 2 ---.Check Protocol Load 
	BEGIN 
		SELECT 1 AS 'SortOrder', 
		'Protocols in Document Table' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.Document where DocumentTypeID in (5, 28) ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.Document where DocumentTypeID in (5, 28) ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.Document where DocumentTypeID in (5, 28) ) AS 'On Staging' 
		UNION 
		SELECT 
		1 AS 'SortOrder', 
		'Active Protocols in Document Table' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.Document where DocumentTypeID in (5, 28) AND IsActive = 1 ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.Document where DocumentTypeID in (5, 28) AND IsActive = 1 ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.Document where DocumentTypeID in (5, 28) AND IsActive = 1 ) AS 'On Staging' 
		UNION 
		SELECT 
		2 AS 'SortOrder', 
		'dbo.Protocol' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.Protocol ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.Protocol ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.Protocol ) AS 'On Staging' 
		UNION 
		SELECT 
		3 AS 'SortOrder', 
		'dbo.ProtocolAlternateID' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.ProtocolAlternateID ) AS 'On Live', 
		( select count(*) from CDRPreviewGK.dbo.ProtocolAlternateID ) AS 'On Preview', 
		( select count(*) from CDRStagingGK.dbo.ProtocolAlternateID ) AS 'On Staging' 
		UNION 
		SELECT 
		4 AS 'SortOrder', 
		'dbo.ProtocolTrialSite' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.ProtocolTrialSite ) AS 'On Live', 
		( select count(*) from CDRPreviewGK.dbo.ProtocolTrialSite ) AS 'On Preview', 
		( select count(*) from CDRStagingGK.dbo.ProtocolTrialSite ) AS 'On Staging' 
		UNION 
		SELECT 
		5 AS 'SortOrder', 
		'dbo.ProtocolLeadOrg' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.ProtocolLeadOrg ) AS 'On Live', 
		( select count(*) from CDRPreviewGK.dbo.ProtocolLeadOrg ) AS 'On Preview', 
		( select count(*) from CDRStagingGK.dbo.ProtocolLeadOrg ) AS 'On Staging' 
		UNION 
		SELECT 
		6 AS 'SortOrder', 
		'dbo.ProtocolDrug' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.ProtocolDrug ) AS 'On Live', 
		( select count(*) from CDRPreviewGK.dbo.ProtocolDrug ) AS 'On Preview', 
		( select count(*) from CDRStagingGK.dbo.ProtocolDrug ) AS 'On Staging' 
		UNION 
		SELECT 
		7 AS 'SortOrder', 
		'dbo.ProtocolModality' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.ProtocolModality ) AS 'On Live', 
		( select count(*) from CDRPreviewGK.dbo.ProtocolModality ) AS 'On Preview', 
		( select count(*) from CDRStagingGK.dbo.ProtocolModality ) AS 'On Staging' 
		UNION 
		SELECT 
		8 AS 'SortOrder', 
		'dbo.ProtocolPhase' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.ProtocolPhase ) AS 'On Live', 
		( select count(*) from CDRPreviewGK.dbo.ProtocolPhase ) AS 'On Preview', 
		( select count(*) from CDRStagingGK.dbo.ProtocolPhase ) AS 'On Staging' 
		UNION 
		SELECT 
		9 AS 'SortOrder', 
		'dbo.ProtocolSponsors' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.ProtocolSponsors ) AS 'On Live', 
		( select count(*) from CDRPreviewGK.dbo.ProtocolSponsors ) AS 'On Preview', 
		( select count(*) from CDRStagingGK.dbo.ProtocolSponsors ) AS 'On Staging' 
		UNION 
		SELECT 
		10 AS 'SortOrder', 
		'dbo.ProtocolDetail' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.ProtocolDetail ) AS 'On Live', 
		( select count(*) from CDRPreviewGK.dbo.ProtocolDetail ) AS 'On Preview', 
		( select count(*) from CDRStagingGK.dbo.ProtocolDetail ) AS 'On Staging' 
		UNION 
		SELECT 
		11 AS 'SortOrder', 
		'dbo.ProtocolStudyCategory' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.ProtocolStudyCategory ) AS 'On Live', 
		( select count(*) from CDRPreviewGK.dbo.ProtocolStudyCategory ) AS 'On Preview', 
		( select count(*) from CDRStagingGK.dbo.ProtocolStudyCategory ) AS 'On Staging' 
		UNION 
		SELECT 
		12 AS 'SortOrder', 
		'ProtocolTypeOfCancer' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.ProtocolTypeOfCancer ) AS 'On Live', 
		( select count(*) from CDRPreviewGK.dbo.ProtocolTypeOfCancer ) AS 'On Preview', 
		( select count(*) from CDRStagingGK.dbo.ProtocolTypeOfCancer ) AS 'On Staging' 
 		ORDER BY SortOrder 
	END	
	ELSE
		IF @ReportNum = 3   --Check Terminology Load
	BEGIN
		SELECT 1 AS 'SortOrder', 
		'Terminology in Document Table' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.Document where DocumentTypeID = 3 ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.Document where DocumentTypeID = 3 ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.Document where DocumentTypeID = 3 ) AS 'On Staging' 
		UNION 
		SELECT 
		3 AS 'SortOrder', 
		'TermDefinition' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.TermDefinition ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.TermDefinition ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.TermDefinition ) AS 'On Staging' 
		UNION 
		SELECT 
		2 AS 'SortOrder', 
		'Terminology' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.Terminology ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.Terminology ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.Terminology ) AS 'On Staging' 
		UNION 
		SELECT 
		4 AS 'SortOrder', 
		'TermOtherName' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.TermOtherName ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.TermOtherName ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.TermOtherName ) AS 'On Staging' 
		UNION 
		SELECT 
		5 AS 'SortOrder', 
		'TermSemanticType' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.TermSemanticType ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.TermSemanticType ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.TermSemanticType ) AS 'On Staging' 
		UNION 
		SELECT 
		6 AS 'SortOrder', 
		'CDRMenus' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.CDRMenus ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.CDRMenus ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.CDRMenus ) AS 'On Staging' 
		ORDER BY SortOrder 
	END
	ELSE
		IF @ReportNum = 4    --Check Glossary Load
	BEGIN
		SELECT 1 AS 'SortOrder', 
		'Glossary in Document Table' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.Document where DocumentTypeID = 26 ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.Document where DocumentTypeID = 26 ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.Document where DocumentTypeID = 26 ) AS 'On Staging' 
		UNION 
		SELECT 
		2 AS 'SortOrder', 
		'GlossaryTerm' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.GlossaryTerm ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.GlossaryTerm ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.GlossaryTerm ) AS 'On Staging' 
		UNION 
		SELECT 
		3 AS 'SortOrder', 
		'GlossaryTermDefinition' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.GlossaryTermDefinition ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.GlossaryTermDefinition ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.GlossaryTermDefinition ) AS 'On Staging' 
		UNION 
		SELECT 
		4 AS 'SortOrder', 
		'GlossaryTermDefinitionAudience' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.GlossaryTermDefinitionAudience ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.GlossaryTermDefinitionAudience ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.GlossaryTermDefinitionAudience ) AS 'On Staging' 
		UNION 
		SELECT 
		5 AS 'SortOrder', 
		'GlossaryTermDefinitionDictionary' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.GlossaryTermDefinitionDictionary ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.GlossaryTermDefinitionDictionary ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.GlossaryTermDefinitionDictionary ) AS 'On Staging' 
		ORDER BY SortOrder 
	END
	ELSE
		IF @ReportNum = 5    ---Check PoliticalSubUnit Load 
	BEGIN
		SELECT 1 AS 'SortOrder', 
		'PoliticalSubUnit in Document Table' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.Document where DocumentTypeID = 8 ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.Document where DocumentTypeID = 8 ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.Document where DocumentTypeID = 8 ) AS 'On Staging' 
		UNION 
		SELECT 
		2 AS 'SortOrder', 
		'PoliticalSubUnit' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.PoliticalSubUnit ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.PoliticalSubUnit ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.PoliticalSubUnit ) AS 'On Staging' 
		ORDER BY SortOrder 
	END
	ELSE
		IF @ReportNum = 6   --Check Organization Load
	BEGIN
		SELECT 1 AS 'SortOrder', 
		'Organization in Document Table' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.Document where DocumentTypeID = 7 ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.Document where DocumentTypeID = 7 ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.Document where DocumentTypeID = 7 ) AS 'On Staging' 
		UNION 
		SELECT 
		2 AS 'SortOrder', 
		'OrganizationName' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.OrganizationName ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.OrganizationName ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.OrganizationName ) AS 'On Staging' 
		ORDER BY SortOrder 
	END
	ELSE
		IF @ReportNum = 7    --Check Genetics Professioal Load 
	BEGIN
		SELECT 1 AS 'SortOrder', 
		'Genetics Professional in Document Table' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.Document where DocumentTypeID = 10 ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.Document where DocumentTypeID = 10 ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.Document where DocumentTypeID = 10 ) AS 'On Staging' 
		UNION 
		SELECT 
		2 AS 'SortOrder', 
		'GenProf' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.GenProf ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.GenProf ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.GenProf ) AS 'On Staging' 
		UNION 
		SELECT 
		3 AS 'SortOrder', 
		'GenProfCancerTypeSite' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.GenProfCancerTypeSite ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.GenProfCancerTypeSite ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.GenProfCancerTypeSite ) AS 'On Staging' 
		UNION 
		SELECT 
		4 AS 'SortOrder', 
		'GenProfFamilyCancerSyndrome' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.GenProfFamilyCancerSyndrome ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.GenProfFamilyCancerSyndrome ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.GenProfFamilyCancerSyndrome ) AS 'On Staging' 
		UNION 
		SELECT 
		5 AS 'SortOrder', 
		'GenProfPracticeLocation' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.GenProfPracticeLocation ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.GenProfPracticeLocation ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.GenProfPracticeLocation ) AS 'On Staging' 
		UNION 
		SELECT 
		6 AS 'SortOrder', 
		'GenProfTypeOfCancer' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.GenProfTypeOfCancer ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.GenProfTypeOfCancer ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.GenProfTypeOfCancer ) AS 'On Staging' 
		ORDER BY SortOrder 
	END
	ELSE
		IF @ReportNum = 8     --Check Document Table and MetaData Tables 
	BEGIN
		SELECT 1 AS 'SortOrder', 
		'Document Table' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.Document ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.Document ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.Document ) AS 'On Staging' 
		UNION 
		SELECT 
		2 AS 'SortOrder', 
		'Active Documents' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.Document WHERE IsActive = 1 ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.Document WHERE IsActive = 1 ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.Document WHERE IsActive = 1 ) AS 'On Staging' 
		UNION 
		SELECT 
		3 AS 'SortOrder', 
		'NOT Active Documents' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.Document WHERE IsActive = 0 ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.Document WHERE IsActive = 0 ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.Document WHERE IsActive = 0 ) AS 'On Staging' 
		UNION 
		SELECT 
		4 AS 'SortOrder', 
		'NOT Loaded Documents' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.Document WHERE Status = 1 ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.Document WHERE Status = 1 ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.Document WHERE Status = 1 ) AS 'On Staging' 
		UNION 
		SELECT 
		5 AS 'SortOrder', 
		'DocumentType table' AS 'Table', 
		( select count(*) from CDRLiveGK.dbo.DocumentType ) AS 'On Live', 
		( select count(*) AS P from CDRPreviewGK.dbo.DocumentType ) AS 'On Preview', 
		( select count(*) AS S from CDRStagingGK.dbo.DocumentType ) AS 'On Staging' 
		ORDER BY SortOrder 
	END

	IF @@ERROR <> 0 
	BEGIN
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Error in usp_GetReports '
		RETURN 100101  --Error code
	END
END

GO
GRANT EXECUTE ON [dbo].[usp_GetReports] TO [Gatekeeper_role]
GO
