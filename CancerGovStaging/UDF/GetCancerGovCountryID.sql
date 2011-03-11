IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetCancerGovCountryID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetCancerGovCountryID]
GO
CREATE FUNCTION dbo.GetCancerGovCountryID( @PDQCountryID int )
RETURNS uniqueidentifier 
AS  

BEGIN 
	RETURN(
		SELECT CancerGov.dbo.GetCancerGovCountryID( @PDQCountryID )
	)
END



GO
