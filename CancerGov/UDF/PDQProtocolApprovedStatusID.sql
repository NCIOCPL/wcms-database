IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDQProtocolApprovedStatusID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[PDQProtocolApprovedStatusID]
GO

/*
Function Return PDQ Protocol Approved - Not yet active Status ID
*/
CREATE FUNCTION [dbo].[PDQProtocolApprovedStatusID] ()  
RETURNS int
WITH SCHEMABINDING
AS  

BEGIN 
	RETURN(2) 
END



GO
