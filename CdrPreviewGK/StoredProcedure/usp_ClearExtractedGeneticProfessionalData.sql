IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_ClearExtractedGeneticProfessionalData]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_ClearExtractedGeneticProfessionalData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_ClearExtractedGeneticProfessionalData    Script Date: 9/10/2002 10:27:49 AM ******/
/*	NCI - National Cancer Institute
*	
*	Purpose:	
*	- Clear previously extracted Genetic Professional data (if any).
*
*	Objects Used:
*
*	Change History:
*
*	To Do List:
*
*/
CREATE PROCEDURE dbo.usp_ClearExtractedGeneticProfessionalData
	(
	@DocumentID int,
	@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	if @isDebug =1  PRINT  '  *** START - Cleaning process for Genetic Professional  ' + convert(varchar, @DocumentID )
	--*******************************************************************************************************************************
	DECLARE @ReturnCode int 
	SELECT @ReturnCode = 0

	--*******************************************************************************************************************************
	-- select * FROM  GenProfTypeOfCancer 
	DELETE FROM  dbo.GenProfTypeOfCancer 
	WHERE GenProfID = @DocumentID
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID,'GenProfTypeofCancer')
		RETURN 69998
	END 

	if @isDebug =1  PRINT  '  ***       - GenProfTypeOfCancer:  deleted.'

	--*******************************************************************************************************************************
	DELETE FROM  dbo.GenProfCancerTypeSite 
	WHERE CancerTypeSiteID NOT IN (
			SELECT DISTINCT CancerTypeSiteID 
			FROM  	dbo.GenProfTypeOfCancer 
			)
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID,'GenProfCancerTypeSite')
		RETURN 69998
	END 

	if @isDebug =1  PRINT  '  ***       - GenProfCancerTypeSite:  deleted.'

	--*******************************************************************************************************************************
	DELETE FROM  dbo.GenProfFamilyCancerSyndrome 
	WHERE GenProfID = @DocumentID
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID,'GenProfFamilyCancerSyndrome')
		RETURN 69998
	END 
	
	if @isDebug =1  PRINT  '  ***       - GenProfFamilyCancerSyndrome:  deleted.'


	--*******************************************************************************************************************************
	DELETE FROM  dbo.GenProfPracticeLocation 
	WHERE GenProfID = @DocumentID
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID,'GenProfPracticeLocation')
		RETURN 69998
	END 

	if @isDebug =1  PRINT  '  ***       - GenProfPracticeLocation:  deleted.'

	--*******************************************************************************************************************************
	DELETE FROM  dbo.GenProf 
	WHERE GenProfID = @DocumentID
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID,'GenProf')
		RETURN 69998
	END 

	if @isDebug =1  PRINT  '  ***       - GenProf:  deleted.'

	--*******************************************************************************************************************************

	DELETE FROM  dbo.DocumentXML
	WHERE DocumentID = @DocumentID
	
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID,'DocumentXML')
		RETURN 69998
	END 
	
	if @isDebug =1  PRINT  '  DOcumentXML  deleted.'




	delete from dbo.cachedocument
	where documentID = @documentID

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID,'CacheDocument')
		RETURN 69998
	END 

	if @isDebug =1  PRINT  '  CacheDOcument  deleted.'

	if @isDebug =1  PRINT  '  *** FINISH - Cleaning process for Genetic Professional  ' + convert(varchar, @DocumentID )
	RETURN  0 
	
END


GO
GRANT EXECUTE ON [dbo].[usp_ClearExtractedGeneticProfessionalData] TO [Gatekeeper_role]
GO
