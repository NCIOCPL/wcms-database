IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetViewURL]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetViewURL]
GO
CREATE FUNCTION [dbo].[udf_GetViewURL] 
	(
	@NCIViewID uniqueidentifier
	)  
RETURNS varchar(1028)  AS  

BEGIN 
	
	RETURN(
	select 	RTRIM(ISNULL(URL,'')) + RTRIM(ISNULL('?' + URLArguments,'')) AS URL 
	from 	nciview
	where 	nciviewid = @NCIViewID 
	)

END

GO
