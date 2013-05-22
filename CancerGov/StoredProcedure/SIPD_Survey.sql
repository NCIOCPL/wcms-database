IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[SIPD_Survey]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[SIPD_Survey]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE  [dbo].[SIPD_Survey]( 
		  @Action varchar(32)
		, @q1  int = 0
		, @q2  int = 0
		, @q3  int = 0
		, @q4  int = 0
		, @q5  int = 0
		, @q6  int = 0
		, @Comments  text = ''
		, @SurveyID bigint = null
	)
	/**************************************************************************************************
	* Name		: [SIPD_Survey]
	* Purpose	: [SIPD_Survey]
	* Author	: [SRamaiah]
	* Date		: [08/02/2006]
	* Returns	: []
	* Usage		: [
				   Exec SIPD_Survey 'Add', 1, 0, 1, 1, 1, 0, 'survey1' 
				   Exec SIPD_Survey 'GetAll', 1, 0, 1, 1, 1, 0, 'survey1' 
				   Exec SIPD_Survey 'Delete', 1, 0, 1, 1, 1, 0, 'survey1', 7 
				  ]
	* Changes	: []
	**************************************************************************************************/
	AS
	BEGIN
	  --Declaration
		Declare @sSql varchar(1024)		
	  --Initialization
		Set @sSql = ''
	  --Execute
		-- BEGIN TRY
		PRINT @sSql
			--TODO: EXECUTE HERE
			If(@Action = 'Add')
			Begin
				Insert Into SIPDSurvey(q1, q2, q3, q4, q5, q6, Comments)
				Values( @q1, @q2, @q3, @q4, @q5, @q6, @Comments)
			End
			Else If(@Action = 'GetAll')
			Begin
				Select * From SIPDSurvey
			End			
			Else If(@Action = 'Delete')
			Begin
				Delete SIPDSurvey Where SurveyID = @SurveyID
			End
			Else If(@Action = 'DeleteAll')
			Begin
				Delete SIPDSurvey
			End
		--- END TRY
		--- BEGIN CATCH 
			--Return Error Number
			--RETURN 99999
		--- END CATCH	  	  	  
	END
	
GO
GRANT EXECUTE ON [dbo].[SIPD_Survey] TO [public]
GO
