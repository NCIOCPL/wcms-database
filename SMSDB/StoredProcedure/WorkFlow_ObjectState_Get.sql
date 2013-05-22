IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WorkFlow_ObjectState_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[WorkFlow_ObjectState_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE  PROCEDURE  [dbo].[WorkFlow_ObjectState_Get]
/**************************************************************************************************
* Name		: WorkFlow_ObjectState_Get
* Purpose	: returns object's state for a given object id
* Author	: SRamaiah
* Date		: 11/27/2006
* Returns	: object's state
* Usage		: Exec WorkFlow_ObjectState_Get '76cff7b2-afbd-4943-bb89-61833218f71d'
			  Exec WorkFlow_ObjectState_Get '3580F767-7D5D-4446-A944-009DE36BB26B'
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
			, w.State
			, dbo.WorkFlow_ObjectState_GetPreviousState(@objectID) as PreviousState
			, w.IsPublished
			, w.Notes
			, w.UpdateUserID
			, w.UpdateDate
		from dbo. WorkFlowStatus w
		where w.objectID = @objectID
	END TRY
	BEGIN CATCH 
		--Return Error Number
		print error_message()
		return 30100
	END CATCH	  	  	  
END

GO
GRANT EXECUTE ON [dbo].[WorkFlow_ObjectState_Get] TO [websiteuser_role]
GO
