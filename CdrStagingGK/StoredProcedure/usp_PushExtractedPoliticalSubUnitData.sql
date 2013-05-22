IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_PushExtractedPoliticalSubUnitData]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_PushExtractedPoliticalSubUnitData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*	NCI - National Cancer Institute
*	
*	Purpose:	
*	- Push Extracted data To CDRPreviewGK	
*
*	Objects Used:
*
*	Change History:
*	Min
*
*	To Do List:
*
*/

CREATE PROCEDURE dbo.usp_PushExtractedPoliticalSubUnitData
	(
	@DocumentID 	int,
	@UpdateUserID 	varchar(50),
	@CleanOldData	varchar(3) = 'YES' , 
	@isDebug bit = 0
	)
AS
BEGIN
	--**************************************************************************************************************
	DECLARE @UpdateDate datetime, @r int

	--**************************************************************************************************************
	SELECT 	@UpdateDate = GETDATE()	
	SELECT 	@UpdateUserID = ISNULL( @updateUserID, USER_NAME()) 

	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           *****************************************************************************'
	if @isDebug =1  PRINT  '           START - Push PoliticalSubUnit data from staging to Preview '

	IF @CleanOldData = 'Yes' 
	BEGIN
		EXEC @r = CDRPreviewGK..usp_ClearExtractedPoliticalSubUnitData @DocumentID
		IF (@@ERROR <> 0) or (@r <>0)
		BEGIN
			
			RAISERROR ( 70001, 16, 1, @documentID, 'PoliticalSubUnit')
			RETURN 70001
		END 
	END

	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           Push dbo.PoliticalSubUnit table '
	INSERT INTO CDRPreviewGK..PoliticalSubUnit 
		(
		CountryID, 
		CountryName, 
		FullName, 
		PoliticalSubUnitID, 
		ShortName, 
		UpdateDate, 
		UpdateUserID
		)
	SELECT 	CountryID, 
		CountryName, 
		FullName, 
		PoliticalSubUnitID, 
		ShortName, 
		@UpdateDate, 
		@UpdateUserID 
	FROM 	CDRStagingGK..PoliticalSubUnit 
	WHERE 	PoliticalSubUnitID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @documentID, 'PoliticalSubUnit')
		RETURN 70000
	END 


	RETURN 0
END

GO
GRANT EXECUTE ON [dbo].[usp_PushExtractedPoliticalSubUnitData] TO [Gatekeeper_role]
GO
