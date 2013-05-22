IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WorkFlow_History_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[WorkFlow_History_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE  PROCEDURE  [dbo].[WorkFlow_History_Get]
/**************************************************************************************************
* Name		: WorkFlow_History_Get
* Purpose	: returns object's state for a given object id
* Author	: SRamaiah
* Date		: 11/27/2006
* Returns	: object's state
* Usage		: Exec WorkFlow_History_Get 'D26A1633-81B8-42D2-82C4-00873A58692F'
* Changes	: 
**************************************************************************************************/
( 
	@objectID uniqueidentifier
)
AS
BEGIN
  --Declaration
  --Initialization
  --Execute
	BEGIN TRY
		set nocount on;
		select
			  w.ObjectID
			, w.TransitionName
			, dbo.WorkFlow_History_GetNextSequenceID(@objectID) as SequenceID
			, w.State
			, w.IsPublished
			, w.Notes
			, w.UpdateUserID
			, w.UpdateDate
		From WorkFlowStatus w
		Where w.ObjectID = @objectID
		Union
		select
			  w.ObjectID
			, w.TransitionName
			, w.SequenceID
			, w.State
			, w.IsPublished
			, w.Notes
			, w.UpdateUserID
			
			, w.UpdateDate
		from dbo. WorkFlowHistory w
		where w.objectID = @objectID
		Order by SequenceID desc
		
		--return title
		Select EventID, Title
		From dbo.ECEvent
		Where EventID = @objectID
	END TRY
	BEGIN CATCH 
		--Return Error Number
		print error_message()
		return 30100
	END CATCH	  	  	  
END

GO
GRANT EXECUTE ON [dbo].[WorkFlow_History_Get] TO [websiteuser_role]
GO
