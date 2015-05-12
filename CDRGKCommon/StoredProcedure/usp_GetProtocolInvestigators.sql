IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetProtocolInvestigators]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetProtocolInvestigators]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_GetProtocolInvestigators    Script Date: 9/14/2005 12:11:50 PM ******/


/*	NCI - National Cancer Institute
*	
*	Purpose:	
*
*	Objects Used:
*
*	Change History:
*	?/?/2003	John Do				Script Created
*	3/1/2004	Alex Pidlisnyy			only include entries that have <Investigator> that have “ref” attribute
*       9/20/2005	Min				CDRID
*	To Do List:
*
*/

CREATE PROCEDURE dbo.usp_GetProtocolInvestigators

	@Keyword		varchar(1000),
	@LookupMethod	varchar(50) = null

AS

BEGIN

	-- SET @Keyword = 'Tchekmedyian%'
	-- SET @Keyword = '%Tchekmedyian%'
	-- SET @LookupMethod = 'NOT KEYWORD'	
set nocount on

	IF LTRIM(RTRIM(NULLIF(@LookupMethod, ''))) = 'KEYWORD'
	BEGIN
		(
		SELECT DISTINCT  personid as CDRID, PersonGivenName + ' ' + PersonSurName As [Name], PersonSurName + ', ' + PersonGivenName + '; ' + City + ', ' + State AS DisplayName
		FROM dbo.vwprotocolInvestigator
		WHERE ((Country = 'U.S.A.' OR Country = 'Canada') AND NULLIF(State, '') IS NOT NULL)
		AND PersonID IS NOT NULL
		AND (PersonSurName like @Keyword OR PersonGivenName like @Keyword)
		AND (NULLIF(PersonGivenName, '') IS NOT NULL)
		AND (NULLIF(PersonSurName, '') IS NOT NULL)
		AND (NULLIF(City, '') IS NOT NULL)
		)
		UNION
		(
		SELECT DISTINCT personid as CDRID, PersonGivenName + ' ' + PersonSurName As [Name], PersonSurName + ', ' + PersonGivenName + '; ' + City + ', ' + Country AS DisplayName
		FROM dbo.vwprotocolInvestigator
		WHERE ((Country <> 'U.S.A.' AND Country <> 'Canada') OR NULLIF (State, '') IS NULL)
		AND PersonID IS NOT NULL
		AND (PersonSurName like @Keyword OR PersonGivenName like @Keyword)
		AND (NULLIF(PersonGivenName, '') IS NOT NULL)
		AND (NULLIF(PersonSurName, '') IS NOT NULL)
		AND (NULLIF(City, '') IS NOT NULL)
		AND (NULLIF(Country, '') IS NOT NULL)
		)
		ORDER BY DisplayName ASC
	END
	ELSE
	BEGIN
		PRINT 'NOT A key word LookUp method'

		SELECT DISTINCT  personid as CDRID,
			PersonGivenName + ' ' + PersonSurName As [Name], 
			PersonSurName + ', ' + PersonGivenName + '; ' + City + ', ' + State AS DisplayName
		FROM 	dbo.vwprotocolInvestigator
		WHERE 	(
				(
					Country = 'U.S.A.' 
					OR Country = 'Canada'
				) 
				AND NULLIF(State, '') IS NOT NULL
			)
			AND PersonSurName like @Keyword
			AND PersonID IS NOT NULL
			AND NULLIF(PersonGivenName, '') IS NOT NULL 
			AND NULLIF(PersonSurName, '') IS NOT NULL 
			AND NULLIF(City, '') IS NOT NULL 
		UNION
		SELECT DISTINCT  personid as CDRID,
			PersonGivenName + ' ' + PersonSurName As [Name], 
			PersonSurName + ', ' + PersonGivenName + '; ' + City + ', ' + Country AS DisplayName
		FROM 	dbo.vwprotocolInvestigator
		WHERE 	(
				(
					Country <> 'U.S.A.' 
					AND Country <> 'Canada'
				) 
				OR NULLIF (State, '') IS NULL
			)
			AND PersonSurName like @Keyword
			AND PersonID IS NOT NULL
			AND NULLIF(PersonGivenName, '') IS NOT NULL 
			AND NULLIF(PersonSurName, '') IS NOT NULL 
			AND NULLIF(City, '') IS NOT NULL 
			AND NULLIF(Country, '') IS NOT NULL 
		ORDER BY DisplayName ASC
	END

END


GO
GRANT EXECUTE ON [dbo].[usp_GetProtocolInvestigators] TO [websiteuser_role]
GO

