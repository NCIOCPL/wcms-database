IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateTopicMacro]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateTopicMacro]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--***********************************************************************
-- Create New Object 
--************************************************************************
/****** 	Object:  Stored Procedure dbo.usp_UpdateTopicMacro
	Owner:	Jay He
	Script Date: 3/17/2003 14:43:49 pM 
	4/4/2003 Jay Added MacroID
	Update a macro and all related nciviews
******/

CREATE PROCEDURE dbo.usp_UpdateTopicMacro
(
	@MacroID 			uniqueidentifier,
	@MacroName			varchar(512),
	@MacroValue			varchar(1024),										 
	@UpdateUserID  		VarChar(40),
	@GroupID			int,
	@AdminURL			varchar(50)
)
AS
BEGIN

	Declare  @return_status		int

	-- Create a temp table to store all related topics and nciview on cancergovstaging
	CREATE TABLE #TempTS (
		[TopicID]      [uniqueidentifier]  ,
		[NCIViewID] [uniqueidentifier]
	);	

	INSERT INTO #TempTS (TopicID, NCIViewID)	
	SELECT ts.TopicID, 
		(SELECT vo.nciviewid 
			from  viewobjects vo 
			where vo.objectid=ts.TopicID) AS NCIViewID
	FROM TSTopics ts where ts.EditableTopicSearchTerm like '%' + @MacroName + '%'


	BEGIN  TRAN   Tran_TS

		-- update CancerGovStaging TSMacros' status to Submit, content 
		UPDATE TSMacros
		set 	MacroValue= @MacroValue,
			Status ='SUBMIT',
			UpdateUserID= @UpdateUserID
		where  MacroName= @MacroName and MacroID= @MacroID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_TS
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

		-- Update CancerGovStaging NCIView status to Submit to prevent any updates during this approval process
		UPDATE NCIView 
		SET 	Status ='LOCKED'
		FROM #TempTS tts, CancerGovStaging..NCIView nv, CancerGovStaging..TSTopics cts
		WHERE tts.nciviewid IS NOT NULL and cts.TopicID = tts.TopicID
			AND tts.nciviewid = nv.nciviewid 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_TS
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

		-- submit for approval

		EXEC  	@return_status= usp_submitMacroForEditApproval  @MacroID, @GroupID, @UpdateUserID, @AdminURL
						
		PRINT '--	return value=' + Convert(varchar(60), @return_status)
		IF @return_status <> 0
		BEGIN
			ROLLBACK TRAN Tran_TS
			RAISERROR ( 80014, 16, 1)
			RETURN  
		END
	COMMIT tran Tran_TS

	Drop table #TempTS

	RETURN 0 

END

GO
GRANT EXECUTE ON [dbo].[usp_UpdateTopicMacro] TO [webadminuser_role]
GO
