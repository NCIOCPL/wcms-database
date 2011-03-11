IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_CheckTopicSearch]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_CheckTopicSearch]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** 	Object:  Stored Procedure dbo.usp_CheckTopicSearch  
	Owner:	Jay He
	Script Date: 3/26/2003 16:30:49 pM 
	Purpose: Check each macro contained in this term. 
		If they are not in Production status,  return a list of macros. 
		So user knows which macro he needs to approve before this term is submitted for approval.
******/

CREATE PROCEDURE dbo.usp_CheckTopicSearch
(	
	@TopicID uniqueidentifier,
	@UpdateUserID	varchar(50)
)
AS
BEGIN
	SET NOCOUNT ON;

	Declare  @Status	varchar(20),
		@MacroName 	varchar(255),
		@ReturnValue	varchar(4000) 

	select @ReturnValue =''

	BEGIN  TRAN   Tran_TS
		
		DECLARE DOC_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
		SELECT 	MacroName, Status
		FROM 		CancerGovStaging..TSMacros
		FOR READ ONLY 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_TS
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
		
		OPEN DOC_Cursor 
		IF (@@ERROR <> 0)
		BEGIN
			DEALLOCATE DOC_Cursor 
			ROLLBACK TRAN Tran_TS
			RAISERROR ( 70004, 16, 1)		
			RETURN 70004
		END 
		
		FETCH NEXT FROM DOC_Cursor
		INTO 	@MacroName, @Status

		WHILE @@FETCH_STATUS = 0
		BEGIN
			if ( exists (select TopicName from TSTopics where TopicID = @TopicID and EditableTopicSearchTerm like '%{' + @MacroName + '}%'))
			BEGIN
				if @Status !='PRODUCTION'
				BEGIN
					select @ReturnValue =@ReturnValue + @MacroName +','
				END
			END		

			-- GET NEXT OBJECT
			PRINT '--get next'
			FETCH NEXT FROM DOC_Cursor 
			INTO 	@MacroName, @Status
		END -- end while

		-- CLOSE doc_Cursor		
		CLOSE  DOC_Cursor
		DEALLOCATE  DOC_Cursor

	COMMIT tran Tran_TS

	SET NOCOUNT OFF

	select @ReturnValue

END
GO
GRANT EXECUTE ON [dbo].[usp_CheckTopicSearch] TO [webadminuser_role]
GO
