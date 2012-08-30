IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Node_SetStatuses]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Node_SetStatuses]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE  PROCEDURE  [dbo].[Core_Node_SetStatuses]
/**************************************************************************************************
* Name		: Core_Node_SetStatuses
* Purpose	:  
* Author	: SRamaiah
* Date		: 10/05/2006
* Returns	: 
* Usage		: Exec Core_Node_SetStatuses '48A5099C-DBF6-4014-9666-08C23D6CBAFD,4E37D3E6-EAB9-4759-985D-13B97F082EB9', 'NIH\ramaiahs'
* Changes	:
**************************************************************************************************/
( 
	@nodeIDs varchar(max)
	, @updateUserID varchar(50)
)
AS
BEGIN
 --Declaration
	Declare @submitStatus int
		, @itemDelimiter varchar(2)
		, @nodeID uniqueidentifier
		, @rtnValue int;
	Declare @Nodes table(NodeID uniqueidentifier)

  --Initialization
	--set nocount on
	set @rtnValue = 0
	set @SubmitStatus = 1 --TODO: change this with right number
	set @itemDelimiter = ',';

  --Execute
	BEGIN TRY				
		Declare cursor_0 cursor for
		select item from dbo.udf_ListToGuid (@nodeIDs, @itemDelimiter)
		Open cursor_0
		Fetch Next From cursor_0 Into @nodeID
		While @@FETCH_STATUS = 0
		Begin
			exec @rtnValue = [dbo].[Workflow_WorkflowItem_Modify] @nodeID, @updateUserID
			--cannot change the status, break 
			if @rtnValue <> 0
				BREAK;
			Fetch Next From cursor_0 Into @nodeID
		End
		Close cursor_0
		Deallocate cursor_0;
		-- return 
		return @rtnValue;
	END TRY
	BEGIN CATCH 
		Print Error_Message()
		RETURN 12015
	END CATCH	 	  	  
END

GO
GRANT EXECUTE ON [dbo].[Core_Node_SetStatuses] TO [websiteuser_role]
GO
