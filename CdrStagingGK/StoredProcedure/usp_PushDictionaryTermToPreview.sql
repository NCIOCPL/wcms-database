

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_PushDictionaryTermToPreview]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_PushDictionaryTermToPreview]
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
*
*/

CREATE PROCEDURE dbo.usp_PushDictionaryTermToPreview
	(
	@TermID		int
	)
AS
BEGIN

	set nocount on 
	
	DECLARE @r int


	BEGIN
		EXEC @r =  CDRPreviewGK.dbo.usp_ClearDictionaryData @TermID
		IF (@@ERROR <> 0) or (@r <>0)
		BEGIN
			
			RAISERROR ( 70001, 16, 1, @TermID, 'Dictionary')
			RETURN 70001
		END 
	END

	--**************************************************************************************************************

	INSERT INTO CDRPreviewGK.dbo.Dictionary
		(
		TermID,
		TermName,
		Dictionary,
		Language,
		Audience,
		ApiVers,
		Object
		)
	SELECT 	TermID,
		TermName,
		Dictionary,
		Language,
		Audience,
		ApiVers,
		Object
	FROM 	CDRStagingGK.dbo.Dictionary
	WHERE 	TermID = @TermID

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @TermID, 'Dictionary')
		RETURN 70000
	END 	

	INSERT INTO CDRPreviewGK.dbo.DictionaryTermAlias
		(
		TermID,
		Othername,
		OtherNameType,
		Language
		)
	SELECT	TermID,
			Othername,
			OtherNameType,
			Language
	FROM 	CDRStagingGK.dbo.DictionaryTermAlias
	WHERE 	TermID = @TermID


	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @TermID, 'Dictionary')
		RETURN 70000
	END 	

END



GO
GRANT EXECUTE ON [dbo].[usp_PushDictionaryTermToPreview] TO [Gatekeeper_role]
GO
