IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDQProtocolActiveStatusID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[PDQProtocolActiveStatusID]
GO

/*
Function Return PDQ Protocol Active Status ID
*/
CREATE FUNCTION [dbo].[PDQProtocolActiveStatusID] ()  
RETURNS int
WITH SCHEMABINDING
AS  

BEGIN 
	RETURN(1) 
END



GO
