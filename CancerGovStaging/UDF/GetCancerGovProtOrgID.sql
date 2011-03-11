IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetCancerGovProtOrgID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetCancerGovProtOrgID]
GO
CREATE FUNCTION dbo.GetCancerGovProtOrgID( @PDQProtOrgID int )
RETURNS uniqueidentifier 
AS  

BEGIN 
	RETURN(
		SELECT CancerGov.dbo.GetCancerGovProtOrgID( @PDQProtOrgID )
	)
END





GO
