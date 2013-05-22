IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetProtocolLeadOrganizations]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetProtocolLeadOrganizations]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_GetProtocolLeadOrganizations    Script Date: 9/14/2005 12:08:08 PM ******/

/*	NCI - National Cancer Institute
*	
*	Purpose:	
*
*	Objects Used:
*
*	Change History:
*	12/31/2003	John Do				Script Created
*	9/20/2005	Min				CDRID
*	To Do List:
*
*/

CREATE PROCEDURE dbo.usp_GetProtocolLeadOrganizations
	(			 		
	@keyword	varchar(1000)
	)
AS
BEGIN
	set nocount on
	SELECT DISTINCT po.organizationid as CDRID, Orgn.Name AS [Name], OrgN.name AS DisplayName
	FROM dbo.protocolleadorg po
	INNER JOIN dbo.OrganizationName AS OrgN
		ON OrgN.OrganizationID = Po.OrganizationID
	WHERE OrgN.name like @keyword
	and (OrganizationRole = 1
	OR
	(OrganizationRole = 2 AND PersonRole = 'PROTOCOL CHAIR')
	)
	AND ProtocolID IN (
		SELECT ProtocolID FROM Protocol WHERE IsActiveProtocol = 1
		)
	
	ORDER BY [Name] ASC
END


GO
GRANT EXECUTE ON [dbo].[usp_GetProtocolLeadOrganizations] TO [websiteuser_role]
GO

