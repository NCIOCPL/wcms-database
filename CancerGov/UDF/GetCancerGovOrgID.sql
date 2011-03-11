IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetCancerGovOrgID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetCancerGovOrgID]
GO


/*
Function translate PDQ OrganizationID in to  CancerGov OrganizationID bace on the data in database.
*/
CREATE FUNCTION dbo.GetCancerGovOrgID( @PDQOrgID int )
RETURNS uniqueidentifier 
WITH SCHEMABINDING
AS  

BEGIN 
	RETURN(
		SELECT 	OrganizationID
		FROM 		dbo.Organization
		 WHERE 	DataSource = dbo.GetPDQDataSourceID()
				AND SourceID = @PDQOrgID
	)
END







GO
