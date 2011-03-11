IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetCancerGovAffiliationID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetCancerGovAffiliationID]
GO
CREATE FUNCTION dbo.GetCancerGovAffiliationID( @PDQAffiliationID int )
RETURNS uniqueidentifier 
AS  

BEGIN 
	RETURN(
		SELECT CancerGov.dbo.GetCancerGovAffiliationID( @PDQAffiliationID )
	)
END


GO
