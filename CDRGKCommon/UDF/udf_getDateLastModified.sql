
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[udf_GetDateLastModified]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[udf_GetDateLastModified]
GO


CREATE FUNCTION [dbo].[udf_GetDateLastModified]
(
	@Documentid	int	
)  
RETURNS DateTime
 AS  
BEGIN 

	RETURN (SELECT DateLastModified FROM dbo.Document WHERE documentid = @Documentid)

END



