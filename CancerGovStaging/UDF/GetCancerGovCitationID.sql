IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetCancerGovCitationID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetCancerGovCitationID]
GO
CREATE FUNCTION dbo.GetCancerGovCitationID( @PDQCitationID int )
RETURNS uniqueidentifier 
AS  

BEGIN 
	RETURN(
		SELECT CancerGov.dbo.GetCancerGovCitationID( @PDQCitationID )
	)
END


GO
