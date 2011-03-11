IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDQProtocolSpecialStatusID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[PDQProtocolSpecialStatusID]
GO
CREATE FUNCTION [dbo].[PDQProtocolSpecialStatusID] ()  
RETURNS int
AS  

BEGIN 
	RETURN( SELECT [CancerGov].[dbo].[PDQProtocolSpecialStatusID] ()  ) 
END



GO
