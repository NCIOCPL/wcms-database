IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WorkFlow_ObjectState_SetPublished]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[WorkFlow_ObjectState_SetPublished]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE  PROCEDURE  [dbo].[WorkFlow_ObjectState_SetPublished]
/**************************************************************************************************
* Name		: WorkFlow_ObjectState_SetPublished
* Purpose	: used to set the isPublished flag to true for a given eventID/objectID
* Author	: SRamaiah
* Date		: 11/27/2006
* Returns	: 0/30102
* Usage		: Exec WorkFlow_ObjectState_SetPublished '76cff7b2-afbd-4943-bb89-61833218f71d'
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
		Begin
			--update workflow status table with current status
			Update WorkFlowStatus
			Set IsPublished = 1
			Where 
				ObjectID = @objectID
		End				
	END TRY
	BEGIN CATCH 
		--Return Error Number
		print error_message()
		return 30105
	END CATCH	  	  	  
END

GO
GRANT EXECUTE ON [dbo].[WorkFlow_ObjectState_SetPublished] TO [websiteuser_role]
GO
