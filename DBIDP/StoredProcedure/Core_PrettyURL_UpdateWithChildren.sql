IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_PrettyURL_UpdateWithChildren]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_PrettyURL_UpdateWithChildren]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE  PROCEDURE  [dbo].[Core_PrettyURL_UpdateWithChildren]
/**************************************************************************************************
* Name		: Core_PrettyURL_UpdateWithChildren
* Purpose	: Updates Pretty URL for parent and it's children for a given PrettyURLID
* Author	: SRamaiah
* Date		: 10/05/2006
* Returns	: 0 or error code
* Usage		: Exec Core_PrettyURL_UpdateWithChildren 'D87969BB-34A8-42E7-AB77-27CE2716091B', '/about', 1, 'NIH\ramaiahs'
			  Select * From dbo.PrettyUrl Where PrettyURL like '%/about%' order by PrettyURL
			  Exec Core_PrettyURL_UpdateWithChildren 'D87969BB-34A8-42E7-AB77-27CE2716091B', '/About', 1, 'NIH\ramaiahs'
			  Select * From dbo.PrettyUrl Where PrettyURL like '%/About%' order by PrettyURL
* Changes	: 10/26/2006 SR - changed to use current status instead of previous status
**************************************************************************************************/
( 
	  @prettyURLID uniqueidentifier
	, @prettyURL varchar(512)
	, @isPrimary bit
	, @updateUserID varchar(50)
)
AS
BEGIN
  --Declaration
	Declare 
		@oldPrettyURL varchar(512)
		, @nodeID uniqueidentifier
		, @count int
		, @rtnValue int

	Declare @nodes table (
		NodeID uniqueidentifier,
		status int
	)

  --Initialization
	--set nocount on
	set @rtnValue = 0
  --Execute
	BEGIN TRY

		--get old pretty URL and node id
		select @OldPrettyURL = PrettyURL, 
			@nodeID = NodeID
		from PrettyURL where PrettyURLID  = @prettyURLID

	    ;
		-- get node ids recursively
		WITH CTE (NodeID, Status) 
		AS
		(
			select @nodeID, dbo.Core_Function_GetCurrentStatus(@nodeID) --include parent nodeid
			union ALL
			select n.NodeID, dbo.Core_Function_GetCurrentStatus(n.NodeID)
			from dbo.Node n
			join CTE on n.ParentNodeID = CTE.NodeID
		)
		
		insert into @nodes
		select NodeID, Status from CTE 
		
		select @Count = count(*) from @nodes where Status <> 1 and Status <> 8; 

		-- Check Status. If any child's status is not Modified or Live (1,8) error out
		if (@Count > 0)
		begin
			set @rtnValue= 50100
		end
		Else
		BEGIN
			--select p.NodeID, p.PrettyURL
			--update pretty url for all the nodes
			update p
			set p.PrettyURL = Replace(p.PrettyURL, @oldPrettyURL, @prettyURL)
				, UpdateUserID = @updateUserID
				, UpdateDate = getdate()
			from dbo.PrettyURL p
			inner join @nodes c
				on p.NodeID = c.NodeID;

			--update parent's isPrimary flag
			update PrettyURL 
			set IsPrimary = @isPrimary
			where NodeID = @nodeID;

			--update the status
			Declare cursor_0 cursor for
			select NodeID from @nodes
			Open cursor_0
			Fetch Next From cursor_0 Into @nodeID
			While @@FETCH_STATUS = 0
			Begin
				exec dbo.Workflow_WorkflowItem_Modify @nodeID, @updateUserID
				Fetch Next From cursor_0 Into @nodeID
			End
			Close cursor_0
			Deallocate cursor_0;
		END
		
		return @rtnValue;
	END TRY
	BEGIN CATCH 
		Print Error_Message()
		RETURN 50107
	END CATCH	  	  
END

GO
GRANT EXECUTE ON [dbo].[Core_PrettyURL_UpdateWithChildren] TO [websiteuser_role]
GO
