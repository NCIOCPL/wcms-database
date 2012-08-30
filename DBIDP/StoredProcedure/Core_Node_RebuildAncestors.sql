IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Node_RebuildAncestors]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Node_RebuildAncestors]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE  PROCEDURE  dbo.Core_Node_RebuildAncestors( 
	@isLive bit = 0
)
/**************************************************************************************************
* Name		: dbo.Core_Node_RebuildAncestors
* Purpose	: Rebuilds ancestors table
* Author	: SRamaiah
* Date		: 10/27/2006
* Params    : isAlive
* Returns	: n/a
* Usage		: exec dbo.Core_Node_RebuildAncestors
* Changes	: 
**************************************************************************************************/
AS
BEGIN
  --Declaration
	Declare @rootNodeID uniqueidentifier
		, @nodeID uniqueidentifier
		, @parentNodeID uniqueidentifier
		, @title varchar(255)
		, @treeLevel int
		, @rowID int
	Declare @nodes table (
		RowID int
		, NodeID uniqueidentifier
		, ParentNodeID uniqueidentifier
		, Title varchar(255)
		, TreeLevel int
	)
	Declare @NodeAncestor table (
		NodeID uniqueidentifier
		, AncestorNodeID uniqueidentifier
		, TreeLevel int
	)

  --Initialization	
	set nocount on;
  --Execute
	BEGIN TRY
		-- get the root Node ID
		Select @rootNodeID = NodeID from dbo.Node where ParentNodeId is null
		;
		WITH CTE (NodeID, ParentNodeID, TreeLevel) 
		AS
		(
			SELECT n.NodeID, 
				ParentNodeID, 
				0 as TreeLevel
			FROM dbo.Node n 
			WHERE NodeID = @rootNodeID
			UNION ALL
			SELECT n.NodeID, 
				n.ParentNodeID, 
				1 + TreeLevel
			FROM dbo.Node n 
			JOIN CTE
			ON n.ParentNodeID = CTE.NodeID
		)

		-- get the ancestors of each node recursively 
		-- order by TreeLevel is rquired to keep the tree level hierarchy.
		-- warning! - removing order by TreeLevel clause in the following select 
		-- statement may produce incorrect results.
		-- store the results in a intermediate table before inseting into the permanent table
		insert into @nodes(RowID, NodeID, ParentNodeID, TreeLevel)
		select Row_Number() over (order by TreeLevel) as RowID, NodeID, ParentNodeID, TreeLevel
		from CTE 
		where TreeLevel > 0;
		
		--update temporary ancesotors table
		Declare @rowNum int
		Set @rowNum = 1
		Select @NodeID = NodeID, @parentNodeID = parentNodeID, @treeLevel = TreeLevel
		From @nodes
		Where rowID = @rowNum
		While @@Rowcount <> 0		
		begin
			If @TreeLevel > 1
			Begin
				Insert Into @NodeAncestor(NodeID, AncestorNodeID, TreeLevel)
				Select @NodeID as NodeID, AncestorNodeID, treeLevel
				From @NodeAncestor Where NodeID = @ParentNodeID
			End

			Insert Into @NodeAncestor(NodeID, AncestorNodeID, TreeLevel)
			Select @NodeID, @ParentNodeID, @treeLevel	
			set @rowNum = @rowNum + 1

			Select @NodeID = NodeID, @parentNodeID = parentNodeID, @treeLevel = TreeLevel
			From @nodes
			Where rowID = @rowNum

		end

--		--Declare cursor_0 cursor for
--		select NodeID, ParentNodeID, Title, TreeLevel from @nodes
--		order by TreeLevel
--		Open cursor_0
--		Fetch Next From cursor_0 Into @nodeID, @parentNodeID, @title, @treeLevel
--		While @@FETCH_STATUS = 0
--		Begin
--			If @TreeLevel > 1
--			Begin
--				Insert Into NodeAncestor(NodeID, AncestorNodeID, TreeLevel)
--				Select @NodeID as NodeID, AncestorNodeID, treeLevel
--				From NodeAncestor Where NodeID = @ParentNodeID
--			End
--
--			Insert Into NodeAncestor(NodeID, AncestorNodeID, TreeLevel)
--			Select @NodeID, @ParentNodeID, @treeLevel	
--			Fetch Next From cursor_0 Into @nodeID, @parentNodeID, @title, @treeLevel
--			--exec dbo.Core_Node_RebuildAncestors
--		End
--		Close cursor_0
--		Deallocate cursor_0;	

		--Truncate NodeAncestor table
		Truncate Table NodeAncestor		
		--return final result set
		Insert Into NodeAncestor(NodeID, AncestorNodeID, TreeLevel)
		select NodeID, AncestorNodeID, TreeLevel from @NodeAncestor
	END TRY
	BEGIN CATCH 
		--Return Error Number
		Print Error_Message()
		RETURN 99999
	END CATCH	  	  	  
END

GO
GRANT EXECUTE ON [dbo].[Core_Node_RebuildAncestors] TO [websiteuser_role]
GO
