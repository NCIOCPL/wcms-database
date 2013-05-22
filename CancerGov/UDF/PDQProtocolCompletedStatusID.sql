IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDQProtocolCompletedStatusID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[PDQProtocolCompletedStatusID]
GO

/*
Function Return PDQ Protocol Completed Status ID
*/
CREATE FUNCTION [dbo].[PDQProtocolCompletedStatusID] ()  
RETURNS int
WITH SCHEMABINDING
AS  

BEGIN 
	RETURN(4) 
END



GO
