IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDQProtocolClosedStatusID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[PDQProtocolClosedStatusID]
GO
CREATE FUNCTION [dbo].[PDQProtocolClosedStatusID] ()  
RETURNS int
AS  

BEGIN 
	RETURN( SELECT [CancerGov].[dbo].[PDQProtocolClosedStatusID] () ) 
END



GO
