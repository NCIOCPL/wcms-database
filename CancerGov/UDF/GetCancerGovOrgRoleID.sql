IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetCancerGovOrgRoleID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetCancerGovOrgRoleID]
GO

/*
Function translate PDQ OrganizationRoleID in to  CancerGov OrganizationRoleID bace on the data in database.
*/
CREATE FUNCTION dbo.GetCancerGovOrgRoleID( @PDQOrgRoleID int )
RETURNS uniqueidentifier 
WITH SCHEMABINDING
AS  

BEGIN 
	RETURN(
		SELECT 	OrganizationRoleID
		FROM 		dbo.OrganizationRole 
		 WHERE 	DataSource = dbo.GetPDQDataSourceID()
				AND SourceID = @PDQOrgRoleID
	)
END








GO
