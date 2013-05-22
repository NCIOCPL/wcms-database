IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RebuildTopicSearch]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RebuildTopicSearch]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** 	Object:  Stored Procedure dbo.usp_RebuildTopicSearch  
	Owner:	Bryan Pizzillo
	Script Date: 3/17/2003 16:30:49 pM 
******/

CREATE PROCEDURE dbo.usp_RebuildTopicSearch
(	
	@MacroID uniqueidentifier,
	@UpdateUserID	varchar(50)
)
AS
BEGIN
	SET NOCOUNT ON;

	Declare  
		@MacroName 	varchar(512),
		@MacroValue	varchar(4000),
		@TopicID uniqueidentifier

	select @MacroName = MacroName, @MacroValue = MacroValue from TSMacros where MacroID  = @MacroID	

	CREATE TABLE #TempTSTopic (
		[TopicID] 	[uniqueidentifier], 
		[NCIViewID] 	[uniqueidentifier],
		[IsOnProduction] [int]
	);

	Insert INTO #TempTSTopic (TopicID, NCIViewID, IsOnProduction)
	SELECT ts.TopicID, 
		(SELECT vo.nciviewid 
			from viewobjects vo 
			where vo.objectid=ts.TopicID) As NCIViewID,
		(select count(*) from CancerGov..TSTopics where TopicID = @TopicID) As IsOnProduction
	FROM TSTopics  ts
	where EditableTopicSearchTerm like '%' + @MacroName + '%'

	BEGIN  TRAN   Tran_TS
		
		-- insert/ update Macro on production

		if(	
			NOT EXISTS (SELECT MacroName FROM CancerGov..TSMacros WHERE MacroID = @MacroID)
		  )	
		BEGIN
			insert into CancerGov..TSMacros
			(MacroName, MacroValue,  IsOnProduction,  Status,     MacroID, updateuserID, updatedate)   
			select MacroName, MacroValue,  1, 'PRODUCTION',     MacroID, @UpdateUserID,  getdate() 
			from CancerGovStaging..TSMacros 
			where MacroID = @MacroID
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_TS
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END
		ELSE
		BEGIN
			PRINT @MacroValue +'++++++++++++++'
			UPDATE CancerGov..TSMacros
			SET 	MacroValue = (select MacroValue from CancerGovStaging..TSMacros where MacroID = @MacroID), 
				IsOnProduction = 1,
				Status ='PRODUCTION'
			WHERE macroID = @MacroID
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_TS
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		-- Update topic om production

		UPDATE ts
		SET 	ts.TopicSearchTerm 		= cts.TopicSearchTerm,
			ts.EditableTopicSearchTerm 	= cts.EditableTopicSearchTerm
		from 	CancerGov..TSTopics ts,  CancerGovStaging..TSTopics cts, #TempTSTopic tts
		where 	ts.TopicID=tts.TopicID and ts.TopicID =cts.TopicID and tts.IsOnProduction =1
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_TS
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

		-- update nciview on staging

		UPDATE nv
		SET 	nv.URL = cnv.URL,
			nv.URLArguments = cnv.URLArguments
		FROM #TempTSTopic tts, CancerGov..NCIView nv, CancerGovStaging..NCIView cnv 
		WHERE tts.nciviewid IS NOT NULL 
			AND tts.nciviewid = nv.nciviewid and nv.NCIViewID = cnv.NCIViewID and tts.IsOnProduction =1
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_TS
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

		UPDATE cnv
		SET 	cnv.Status = 'PRODUCTION',
			cnv.IsOnProduction =1
		FROM #TempTSTopic tts, CancerGov..NCIView nv, CancerGovStaging..NCIView cnv 
		WHERE tts.nciviewid IS NOT NULL 
			AND tts.nciviewid = nv.nciviewid and nv.NCIViewID = cnv.NCIViewID and tts.IsOnProduction =1
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_TS
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

		UPDATE cnv
		SET 	cnv.Status = 'EDIT'
		FROM #TempTSTopic tts, CancerGovStaging..NCIView cnv 
		WHERE tts.nciviewid =  cnv.NCIViewID and tts.IsOnProduction =0
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_TS
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

		-- update Macro on staging

		UPDATE CancerGovStaging..TSMacros
		SET 	IsOnProduction = 1,
			Status ='PRODUCTION'
		WHERE macroID = @MacroID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_TS
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 


	COMMIT tran Tran_TS

	Drop table #TempTSTopic

SET NOCOUNT OFF
RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_RebuildTopicSearch] TO [webadminuser_role]
GO
