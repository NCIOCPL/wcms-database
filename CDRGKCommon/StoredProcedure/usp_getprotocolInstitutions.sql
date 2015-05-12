
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetProtocolInstitutions]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetProtocolInstitutions]
GO
/****** Object:  Stored Procedure dbo.usp_GetProtocolInstitutions    Script Date: 9/14/2005 12:05:22 PM ******/
CREATE PROCEDURE usp_GetProtocolInstitutions

	@keyword	varchar(1000)

AS
begin
	
	(SELECT DISTINCT t.organizationid as CDRID, t.OrganizationName AS [Name], t.OrganizationName + ', ' + City + ', ' + State AS DisplayName
	FROM dbo.Protocoltrialsite t 
	WHERE ((Country = 'U.S.A.' OR Country = 'Canada') AND NULLIF(State, '') IS NOT NULL)
	AND t.OrganizationName like @keyword
	AND (NULLIF(City, '') IS NOT NULL)
	)
	UNION
	(
	SELECT DISTINCT t.organizationid as CDRID, t.OrganizationName [Name], t.OrganizationName + ', ' + City + ', ' + Country AS DisplayName
	FROM dbo.Protocoltrialsite t 
	WHERE ((Country <> 'U.S.A.' AND Country <> 'Canada') OR NULLIF(State, '') IS NULL)
	AND t.OrganizationName like @keyword
	AND (NULLIF(City, '') IS NOT NULL)
	AND (NULLIF(Country, '') IS NOT NULL)
	)
	ORDER BY DisplayName ASC

end
	


GO
GRANT EXECUTE ON [dbo].[usp_GetProtocolInstitutions] TO [websiteuser_role]
GO
