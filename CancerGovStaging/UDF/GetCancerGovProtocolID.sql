IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetCancerGovProtocolID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetCancerGovProtocolID]
GO
CREATE FUNCTION dbo.GetCancerGovProtocolID( @PDQProtocolID int )
RETURNS uniqueidentifier 
AS  

BEGIN 
	RETURN(
		SELECT CancerGov.dbo.GetCancerGovProtocolID( @PDQProtocolID )
	)
END


GO
