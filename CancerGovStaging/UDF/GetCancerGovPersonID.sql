IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetCancerGovPersonID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetCancerGovPersonID]
GO
CREATE FUNCTION dbo.GetCancerGovPersonID( @PDQPersonID int )
RETURNS uniqueidentifier 
AS  

BEGIN 
	RETURN(
		SELECT CancerGov.dbo.GetCancerGovPersonID( @PDQPersonID )
	)
END



GO
