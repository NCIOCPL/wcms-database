IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Function_GetRealURL]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Core_Function_GetRealURL]
GO


Create FUNCTION [dbo].Core_Function_GetRealURL(
	@NodeID uniqueidentifier 
)
RETURNS varchar(512)
AS

BEGIN
	Declare @returnvalue  varchar(512)
	
	Select @returnvalue ='/pages/content.aspx?NodeID='+ convert(varchar(36), @NodeID)
	From dbo.LayoutDefinition D, dbo.LayoutTemplate T
	WHERE  D.NodeID = @NodeID  and D.LayoutTemplateID = T.LayoutTemplateID 

	RETURN @returnvalue
END

GO
