IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Function_GetChildNodes]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Core_Function_GetChildNodes]
GO

create function DBO.Core_Function_GetChildNodes (
	@NodeID uniqueIdentifier
)
returns @Child TABLE(
	RowNumber int identity(1,1),
	ID varchar(255)
)
as 

BEGIN

	WITH Node_CTE (NodeID)
	AS
	(
		SELECT NodeID
		FROM dbo.Node 
		WHERE  ParentNodeID = @NodeID
		UNION ALL
		SELECT N.NodeID
		From dbo.Node N
		Join  Node_CTE on
		Node_CTE.NodeID = N.ParentNodeID
	)

	insert into @Child
	(ID)
	SELECT NodeID
	From Node_CTE

	return 
END

GO
