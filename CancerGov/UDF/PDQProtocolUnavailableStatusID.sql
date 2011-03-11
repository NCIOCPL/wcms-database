IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDQProtocolUnavailableStatusID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[PDQProtocolUnavailableStatusID]
GO

/*
Function Return PDQ Protocol Unavailable Status ID
*/
CREATE FUNCTION [dbo].[PDQProtocolUnavailableStatusID] ()  
RETURNS int
WITH SCHEMABINDING
AS  

BEGIN 
	RETURN(200) 
END






GO
