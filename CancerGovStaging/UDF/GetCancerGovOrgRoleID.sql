IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetCancerGovOrgRoleID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetCancerGovOrgRoleID]
GO
CREATE FUNCTION dbo.GetCancerGovOrgRoleID( @PDQOrgRoleID int )
RETURNS uniqueidentifier 
AS  

BEGIN 
	RETURN(
		SELECT CancerGov.dbo.GetCancerGovOrgRoleID( @PDQOrgRoleID )
	)
END


GO
