IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetProtocolInvestigatorsByID]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetProtocolInvestigatorsByID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE dbo.usp_GetProtocolInvestigatorsByID

	     @IDList varchar(4000)

AS
BEGIN

	Declare @InvestigatorIDs Table(item int)

	insert into @InvestigatorIDs
	select objectID from udf_GetComaSeparatedIDs(@IDList)

	select CDRID, [Name], DisplayName from
	(
		SELECT DISTINCT  personid as CDRID, PersonGivenName + ' ' + PersonSurName As [Name],
			(select Top 1 PersonSurName + ', ' + PersonGivenName + '; ' + City + ', ' + Country AS DisplayName
			from dbo.vwprotocolInvestigator vwpi
			where vwpi.personid = qryVwpi.personid) AS DisplayName
		FROM dbo.vwprotocolInvestigator qryVwpi
		WHERE ((Country = 'U.S.A.' OR Country = 'Canada') AND NULLIF(State, '') IS NOT NULL)
		AND PersonID IS NOT NULL
		AND (PersonID in (select item from @InvestigatorIDs))
		AND (NULLIF(PersonGivenName, '') IS NOT NULL)
		AND (NULLIF(PersonSurName, '') IS NOT NULL)
		AND (NULLIF(City, '') IS NOT NULL)

	UNION

		SELECT DISTINCT personid as CDRID, PersonGivenName + ' ' + PersonSurName As [Name],
			(select Top 1 PersonSurName + ', ' + PersonGivenName + '; ' + City + ', ' + Country AS DisplayName
			from dbo.vwprotocolInvestigator vwpi
			where vwpi.personid = qryVwpi.personid) AS DisplayName
		FROM dbo.vwprotocolInvestigator qryVwpi
		WHERE ((Country <> 'U.S.A.' AND Country <> 'Canada') OR NULLIF (State, '') IS NULL)
		AND PersonID IS NOT NULL
		AND (PersonID in (select item from @InvestigatorIDs))
		AND (NULLIF(PersonGivenName, '') IS NOT NULL)
		AND (NULLIF(PersonSurName, '') IS NOT NULL)
		AND (NULLIF(City, '') IS NOT NULL)
		AND (NULLIF(Country, '') IS NOT NULL)
	) tbl
	ORDER BY DisplayName ASC


END
GO
GRANT EXECUTE ON [dbo].[usp_GetProtocolInvestigatorsByID] TO [websiteuser_role]
GO
