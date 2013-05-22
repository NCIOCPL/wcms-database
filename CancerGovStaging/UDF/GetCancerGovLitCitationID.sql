IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetCancerGovLitCitationID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetCancerGovLitCitationID]
GO
CREATE FUNCTION dbo.GetCancerGovLitCitationID( @PDQLitCitationID int )
RETURNS uniqueidentifier 
AS  

BEGIN 
	RETURN(
		SELECT CancerGov.dbo.GetCancerGovLitCitationID( @PDQLitCitationID )
	)
END


GO
