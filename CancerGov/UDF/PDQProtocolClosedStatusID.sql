IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDQProtocolClosedStatusID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[PDQProtocolClosedStatusID]
GO

/*
Function Return PDQ Protocol Closed Status ID
*/
CREATE FUNCTION [dbo].[PDQProtocolClosedStatusID] ()  
RETURNS int
WITH SCHEMABINDING
AS  

BEGIN 
	RETURN(3) 
END



GO
