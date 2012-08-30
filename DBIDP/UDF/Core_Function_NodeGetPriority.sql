IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Function_NodeGetPriority]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Core_Function_NodeGetPriority]
GO


Create FUNCTION [dbo].Core_Function_NodeGetPriority(
	@ParentNodeID uniqueidentifier = null,
	@NodeID uniqueidentifier 
)

RETURNS int
AS

BEGIN
	Declare @returnvalue  int

	if (@ParentNodeID is null)
	BEGIN
		if (exists (select 1 from dbo.Node where ParentNodeID is null))
		BEGIN
			select @returnvalue= max(priority) + 1 from dbo.Node where ParentNodeID is null
		END
		ELSE
		BEGIN
			select @returnvalue =1
		END
	END
	ELSE
	BEGIN
		if (exists (select 1 from dbo.Node where ParentNodeID = @ParentNodeID))
		BEGIN
			select @returnvalue= max(priority) + 1 from dbo.Node where ParentNodeID  = @ParentNodeID
		END
		ELSE
		BEGIN
			select @returnvalue =1
		END
	END

	RETURN @returnvalue
END

GO
