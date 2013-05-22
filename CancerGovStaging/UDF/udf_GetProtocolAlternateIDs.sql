IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetProtocolAlternateIDs]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetProtocolAlternateIDs]
GO
/******************************************
Function return Alternate protocol IDs for given ProtocolID
******************************************/
CREATE FUNCTION [dbo].[udf_GetProtocolAlternateIDs] 
	( 
	@ProtocolID uniqueidentifier
	)  
RETURNS varchar(256) 
AS  

BEGIN 
	RETURN (SELECT  [CancerGov].[dbo].[udf_GetProtocolAlternateIDs] ( @ProtocolID ))
END



GO
