IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Function_PrettyURLExists]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Core_Function_PrettyURLExists]
GO


Create FUNCTION [dbo].Core_Function_PrettyURLExists(
	@PrettyUrlID uniqueidentifier = null
    ,@PrettyURL varchar(512)
)
RETURNS bit
AS

BEGIN
	Declare @returnvalue bit
	
	if (exists (select 1 from dbo.PrettyUrl
		where PrettyURL = @PrettyURL 
		and (@PrettyUrlID is null or PrettyUrlID != @PrettyUrlID)))
	BEGIN
		select @returnvalue = 1
	END
	else
	BEGIN
		select @returnvalue = 0
	END

	RETURN @returnvalue
END

GO
