IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_ClearExtractedProtocolData]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_ClearExtractedProtocolData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*	NCI - National Cancer Institute
*	
*	Purpose:	
*	- Clear previously extracted protocol data (if any).
*
*	Objects Used:
*
*	Change History:
*	6/17/2001 	Alex Pidlisnyy	Script Created
*	8/21/2002 	Alex Pidlisnyy	Add script to clear document properties
*	9/4/2002 	Alex Pidlisnyy	Add @ClearProperties flag 
*	6/13/2003 	Alex Pidlisnyy	add script to clead data from tables 
*					[dbo].[ProtocolContactInfoHtmlMap], 
*					[dbo].[ProtocolContactInfoHTML], 
*					[dbo].[ProtocolSection].
*	2/8/2005	Chen Ling	remove ProtocolOldID entries
*	7/26/2005	Chen Ling	ProtocolSpecialCategory
*	12/04/2009	Blair Learn Clear ProtocolSecondaryUrl
*
*	To Do List:
*	- use transactions
*
*/
CREATE PROCEDURE dbo.usp_ClearExtractedProtocolData
	(
	@DocumentID int,
	@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	if @isDebug = 1 		PRINT  '  *** START - Cleaning process for protocol ' + convert(varchar, @DocumentID )

-- This first commented out block is evidently included to make it clear how the
-- staging version of ClearExtractedProtocolData differs from the versions on 
-- preview and live.  The contents of ProtocolOldID are never deleted on staging,
-- but they are deleted on Preview and Live.  Because the promotion process works
-- by copying data from staging to preview to live, the net effect is that the
-- data is never permanently deleted from the latter databases.

--
--	DELETE FROM [dbo].[ProtocolOldID] WHERE [ProtocolID] = @DocumentID
--	IF (@@ERROR <> 0)
--	BEGIN
--		
--		RAISERROR ( 69998, 16, 1, @DocumentID, 'ProtocolOldID')
--		RETURN 69998
--	END 
	


	DELETE m
	FROM [dbo].[ProtocolContactInfoHtmlMap] m  with (TABLOCKX) inner join dbo.protocoltrialsite t
	on 	m.protocolcontactinfoID = t.protocolcontactinfoID	
	WHERE 	ProtocolID = @DocumentID

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'ProtocolContactInfoHtmlMap')
		RETURN 69998
	END 
			

	DELETE m
	FROM [dbo].[ProtocolContactInfoHtmlMap] m inner join dbo.protocolLeadorg L
	on 	m.protocolcontactinfoID = L.protocolcontactinfoID	
	WHERE 	ProtocolID = @DocumentID

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'ProtocolContactInfoHtmlMap')
		RETURN 69998
	END 


	if @isDebug = 1 		PRINT  '  ***       - ProtocolContactInfoHtmlMap deleted.'

	

	DELETE FROM [dbo].[ProtocolContactInfoHTML] WHERE [ProtocolID] = @DocumentID
		IF (@@ERROR <> 0)
	BEGIN
	
		RAISERROR ( 69998, 16, 1, @DocumentID, 'ProtocolContactInfoHtml')
		RETURN 69998
	END 



	if @isDebug = 1 		PRINT  '  ***       - ProtocolContactInfoHtml deleted.'

	DELETE FROM [dbo].[ProtocolSection] WHERE [ProtocolID] = @DocumentID
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'ProtocolSection')
		RETURN 69998
	END 
	if @isDebug = 1 		PRINT  '  ***       - ProtocolSection deleted.'

	DELETE FROM dbo.ProtocolAlternateID WHERE ProtocolID = @DocumentID
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'ProtocolAlternateID')
		RETURN 69998
	END 

	if @isDebug = 1 		PRINT  '  ***       - ProtocolAlternateID deleted.'

	DELETE FROM dbo.ProtocolSecondaryUrl WHERE ProtocolID = @DocumentID
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'ProtocolSecondaryUrl')
		RETURN 69998
	END 

	if @isDebug = 1 		PRINT  '  ***       - ProtocolSecondaryUrl deleted.'

	DELETE FROM dbo.ProtocolTrialSite WHERE ProtocolID = @DocumentID
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'ProtocolTrialSite')
		RETURN 69998
	END 

	if @isDebug = 1 		PRINT  '  ***       - ProtocolTrialSite deleted.'

	DELETE FROM dbo.ProtocolLeadOrg WHERE ProtocolID = @DocumentID
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'ProtocolLeadOrg')
		RETURN 69998
	END 

	if @isDebug = 1 		PRINT  '  ***       - ProtocolLeadOrg deleted.'

	DELETE FROM dbo.ProtocolDrug WHERE ProtocolID = @DocumentID
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'ProtocolDrug')
		RETURN 69998
	END 

	if @isDebug = 1 		PRINT  '  ***       - ProtocolDrug deleted.'

	DELETE FROM dbo.ProtocolModality WHERE ProtocolID = @DocumentID

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'ProtocolModality')
		RETURN 69998
	END 

	if @isDebug = 1 		PRINT  '  ***       - ProtocolModality deleted.'

	DELETE FROM dbo.ProtocolPhase WHERE ProtocolID = @DocumentID
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'ProtocolPhase')
		RETURN 69998
	END 

	if @isDebug = 1 		PRINT  '  ***       - ProtocolPhase deleted.'

	DELETE FROM dbo.ProtocolSpecialCategory WHERE ProtocolID = @DocumentID
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'ProtocolSpecialCategory')
		RETURN 69998
	END 

	if @isDebug = 1 		PRINT  '  ***       - ProtocolSpecialCategory: ' + convert(varchar, @@RowCount) + ' records deleted.'

	DELETE FROM dbo.ProtocolSponsors WHERE ProtocolID = @DocumentID
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'ProtocolSponsors')
		RETURN 69998
	END 

	if @isDebug = 1 		PRINT  '  ***       - ProtocolSponsors deleted.'

	DELETE FROM dbo.ProtocolStudyCategory WHERE ProtocolID = @DocumentID
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'ProtocolStudyCategory')
		RETURN 69998
	END 

	if @isDebug = 1 		PRINT  '  ***       - ProtocolStudyCategory deleted.'

	DELETE FROM dbo.ProtocolTypeOfCancer WHERE ProtocolID = @DocumentID
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'ProtocolTypeOfCancer')
		RETURN 69998
	END 
	if @isDebug = 1 		PRINT  '  ***       - ProtocolTypeOfCancer deleted.'

	DELETE FROM dbo.ProtocolDetail WHERE ProtocolID = @DocumentID
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'ProtocolDetail')
		RETURN 69998
	END 
	if @isDebug = 1 		PRINT  '  ***       - ProtocolDetail deleted.'

	DELETE FROM dbo.Protocol WHERE ProtocolID = @DocumentID
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'Protocol')
		RETURN 69998
	END 
	if @isDebug = 1 		PRINT  '  ***       - Protocol deleted.'

--	delete from dbo.sponsor where sponsorID not in (select sponsorid from dbo.protocolSponsors)
--	IF (@@ERROR <> 0)
--	BEGIN
--		
--		RAISERROR ( 69998, 16, 1, @DocumentID, 'Sponsor')
--		RETURN 69998
--	END 
--	if @isDebug = 1 		PRINT  '  ***       - Sponsor deleted.'
--
--	delete from dbo.AlternateIDType where idTypeID not in (select IDTypeid from dbo.protocolAlternateID) and IDtypeID > 7
--	IF (@@ERROR <> 0)
--	BEGIN
--		
--		RAISERROR ( 69998, 16, 1, @DocumentID, 'AlternateIDType')
--		RETURN 69998
--	END 
--	if @isDebug = 1 		PRINT  '  ***       - AlternateIDType deleted.'
--
--	delete from dbo.studyCategory 
--		where studyCategoryID not in (select StudyCategoryid from dbo.protocolStudyCategory) 
--	IF (@@ERROR <> 0)
--	BEGIN
--		
--		RAISERROR ( 69998, 16, 1, @DocumentID, 'StudyCategory')
--		RETURN 69998
--	END 
--	if @isDebug = 1 		PRINT  '  ***       - studyCategory deleted.'
--
--	delete from dbo.Modality where ModalityID not in (select Modalityid from dbo.protocolModality)
--	IF (@@ERROR <> 0)
--	BEGIN
--		
--		RAISERROR ( 69998, 16, 1, @DocumentID, 'Modality')
--		RETURN 69998
--	END 
--	if @isDebug = 1 		PRINT  '  ***       - Modality deleted.'




END


GO
GRANT EXECUTE ON [dbo].[usp_ClearExtractedProtocolData] TO [Gatekeeper_role]
GO
