

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_PushDictionaryTermToLive]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_PushDictionaryTermToLive]
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

CREATE PROCEDURE dbo.usp_PushDictionaryTermToLive
	(
	@TermID		int
	)
AS
BEGIN

	set nocount on 
	
	DECLARE @r int


	BEGIN
		EXEC @r =  CDRLiveGK.dbo.usp_ClearDictionaryData @TermID
		IF (@@ERROR <> 0) or (@r <>0)
		BEGIN
			
			RAISERROR ( 70001, 16, 1, @TermID, 'Dictionary')
			RETURN 70001
		END 
	END

	--**************************************************************************************************************

	INSERT INTO CDRLiveGK.dbo.Dictionary
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
	FROM 	CDRPreviewGK.dbo.Dictionary
	WHERE 	TermID = @TermID

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @TermID, 'Dictionary')
		RETURN 70000
	END 	

END



GO
GRANT EXECUTE ON [dbo].[usp_PushDictionaryTermToLive] TO [Gatekeeper_role]
GO
