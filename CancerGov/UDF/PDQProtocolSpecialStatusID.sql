IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDQProtocolSpecialStatusID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[PDQProtocolSpecialStatusID]
GO

/*
Function Return PDQ Protocol Special Status ID
*/
CREATE FUNCTION [dbo].[PDQProtocolSpecialStatusID] ()  
RETURNS int
WITH SCHEMABINDING
AS  

BEGIN 
	RETURN(86) 
END






GO
