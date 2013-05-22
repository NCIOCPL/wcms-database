IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WorkFlow_History_Insert]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[WorkFlow_History_Insert]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE  PROCEDURE  [dbo].[WorkFlow_History_Insert]
/**************************************************************************************************
* Name		: WorkFlow_History_Insert
* Purpose	: Adds a record into WorkFlow History table
* Author	: SRamaiah
* Date		: 11/27/2006
* Returns	: 0(succes)/30201(failure)
* Usage		: Exec WorkFlow_History_Insert '76cff7b2-afbd-4943-bb89-61833218f71d', 'Save', 'Draft', 0, 'Notes-Saved', '5188146770731162715'
* Changes	: 
**************************************************************************************************/
( 
	@objectID uniqueidentifier
	, @transitionName varchar(255)
	, @state varchar(100)
	, @isPublished bit
	, @notes varchar(MAX)
	, @updateUserID uniqueidentifier
)
AS
BEGIN
  --Declaration
  --Initialization
  --Execute
	BEGIN TRY
		set nocount on;
		Insert Into WorkFlowHistory(
			  ObjectID
			, SequenceID
			, TransitionName			
			, State
			, IsPublished
			, Notes
			, UpdateUserID
			, UpdateDate
		)
		Values(
			  @objectID
			, dbo.WorkFlow_History_GetNextSequenceID(@objectID)
			, @transitionName
			, @state
			, @isPublished
			, @notes
			, @updateUserID
			, getdate()
		)		
	END TRY
	BEGIN CATCH 
		--Return Error Number
		print error_message()
		return 30201
	END CATCH	  	  	  
END

GO
GRANT EXECUTE ON [dbo].[WorkFlow_History_Insert] TO [websiteuser_role]
GO
