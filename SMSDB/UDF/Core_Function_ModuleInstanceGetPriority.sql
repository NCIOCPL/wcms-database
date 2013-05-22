IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Function_ModuleInstanceGetPriority]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Core_Function_ModuleInstanceGetPriority]
GO


Create FUNCTION [dbo].Core_Function_ModuleInstanceGetPriority(
	@ZoneInstanceID uniqueidentifier 
)
RETURNS int
AS

BEGIN
	Declare @returnvalue  int

		if (exists (select 1 from dbo.ModuleInstance where ZoneInstanceID = @ZoneInstanceID))
		BEGIN
			select @returnvalue= max(priority) + 1 from dbo.ModuleInstance where ZoneInstanceID = @ZoneInstanceID
		END
		ELSE
		BEGIN
			select @returnvalue =1
		END

	RETURN @returnvalue
END

GO
