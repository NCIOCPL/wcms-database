IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDQProtocolTempClosedStatusID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[PDQProtocolTempClosedStatusID]
GO

/*
Function Return PDQ Protocol Temporarily Closed Status ID
*/
CREATE FUNCTION [dbo].[PDQProtocolTempClosedStatusID] ()  
RETURNS int
WITH SCHEMABINDING
AS  

BEGIN 
	RETURN(5) 
END




GO
