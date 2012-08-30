IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_function_PrimaryPrettyURLCount]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Core_function_PrimaryPrettyURLCount]
GO
create function [dbo].[Core_function_PrimaryPrettyURLCount] 
	(@isPrimary bit, @nodeid uniqueidentifier)
	returns int
	as
	
begin
		
		if @isPrimary = 1
			return (select count(*) from dbo.[prettyURL] 
				where isPrimary =1 and nodeid= @nodeID )
		
		return 0
			
	end

GO
