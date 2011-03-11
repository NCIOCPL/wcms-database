IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDQProtocolActiveStatusID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[PDQProtocolActiveStatusID]
GO
CREATE FUNCTION [dbo].[PDQProtocolActiveStatusID] ()  
RETURNS int
AS  

BEGIN 
	RETURN( SELECT [CancerGov].[dbo].[PDQProtocolActiveStatusID]() ) 
END




GO
