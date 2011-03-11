IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDQProtocolUnavailableStatusID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[PDQProtocolUnavailableStatusID]
GO
CREATE FUNCTION [dbo].[PDQProtocolUnavailableStatusID] ()  
RETURNS int
AS  

BEGIN 
	RETURN( SELECT [CancerGov].[dbo].[PDQProtocolUnavailableStatusID]() ) 
END



GO
