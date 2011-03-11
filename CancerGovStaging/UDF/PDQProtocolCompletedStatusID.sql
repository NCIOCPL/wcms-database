IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDQProtocolCompletedStatusID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[PDQProtocolCompletedStatusID]
GO
CREATE FUNCTION [dbo].[PDQProtocolCompletedStatusID] ()  
RETURNS int
AS  

BEGIN 
	RETURN( SELECT [CancerGov].[dbo].[PDQProtocolCompletedStatusID] () ) 
END



GO
