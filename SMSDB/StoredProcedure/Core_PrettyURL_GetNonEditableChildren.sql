IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_PrettyURL_GetNonEditableChildren]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_PrettyURL_GetNonEditableChildren]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE  PROCEDURE  [dbo].[Core_PrettyURL_GetNonEditableChildren]
/**************************************************************************************************
* Name		: Core_PrettyURL_GetNonEditableChildren
* Purpose	: A proc that finds all of the children that may be affected by this and tell the user about those Pages
* Author	: SRamaiah
* Date		: 10/06/2006
* Returns	: 0 if no children affected or error code(501081)
* Usage		: Exec Core_PrettyURL_GetNonEditableChildren 'D87969BB-34A8-42E7-AB77-27CE2716091B'
* Changes	: 10/26/2006 SR - changed to use current status instead of previous status
**************************************************************************************************/
( 
  @prettyURLID uniqueidentifier
)
AS
BEGIN
  --Declaration
	Declare 
		@oldPrettyURL varchar(512)
		, @nodeID uniqueidentifier
		, @count int
		, @title varchar(255)

	Declare @nodes table (
		NodeID uniqueidentifier
		, Status int
		, Title varchar(255)
		--, PrettyURL varchar(512)
	)

  --Initialization
	set nocount on
  --Execute
	BEGIN TRY

		--get old pretty URL and node id
		select @OldPrettyURL = PrettyURL
			, @nodeID = p.NodeID
			, @title = n.Title
		from PrettyURL p
			join Node n 
			on p.NodeID = n.NodeID
				and PrettyURLID  = @prettyURLID
	    ;
		-- get node ids recursively
		WITH CTE (NodeID, Status, Title) 
		AS
		(
			select @nodeID, dbo.Core_Function_GetCurrentStatus(@nodeID), @title --include parent nodeid
			union ALL
			select n.NodeID, dbo.Core_Function_GetCurrentStatus(n.NodeID), n.Title
			from dbo.Node n
				join CTE on n.ParentNodeID = CTE.NodeID
		)

		-- Check Status. If any child's status is not Modified or Live (1,8) error out
		insert into @nodes(NodeID, status, Title)
		select NodeID, Status, Title from CTE 
		where Status <> 1 and Status <> 8;
		
		--return the final resultset
		select n.NodeID, n.Status, n.Title, p.PrettyURL 
		from @nodes n
			join dbo.PrettyURL p
			on n.NodeID = p.NodeID

		return 0;
	END TRY
	BEGIN CATCH 
		Print Error_Message()
		RETURN 501080
	END CATCH	  	  
END

GO
GRANT EXECUTE ON [dbo].[Core_PrettyURL_GetNonEditableChildren] TO [websiteuser_role]
GO
