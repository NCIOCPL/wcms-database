IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetProtocolLeadOrganizationsByID]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetProtocolLeadOrganizationsByID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE dbo.usp_GetProtocolLeadOrganizationsByID

	     @IDList varchar(4000)

AS
BEGIN

	Declare @OrganizationIDs Table(item int)

	insert into @OrganizationIDs
	select objectID from udf_GetComaSeparatedIDs(@IDList)


	SELECT DISTINCT po.organizationid as CDRID,
		(select top(1) [Name] from OrganizationName AS OrgN where OrgN.OrganizationID = Po.OrganizationID ORDER BY [Name]) As [Name],
		(select top(1) [Name] from OrganizationName AS OrgN where OrgN.OrganizationID = Po.OrganizationID ORDER BY [Name]) AS DisplayName
	FROM dbo.protocolleadorg po
	WHERE po.organizationid in (select item from @OrganizationIDs)
	and (OrganizationRole = 1 OR
		(OrganizationRole = 2 AND PersonRole = 'PROTOCOL CHAIR') )
	AND ProtocolID IN ( SELECT ProtocolID FROM Protocol WHERE IsActiveProtocol = 1 )
	ORDER BY [Name] ASC

END
GO
GRANT EXECUTE ON [dbo].[usp_GetProtocolLeadOrganizationsByID] TO [websiteuser_role]
GO
