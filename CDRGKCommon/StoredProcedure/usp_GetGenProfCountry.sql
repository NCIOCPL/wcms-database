IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetGenProfCountry]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetGenProfCountry]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/****** Object:  Stored Procedure dbo.usp_GetGenProfCountry    Script Date: 2/2/2005 12:15:24 PM ******/
/*	NCI - National Cancer Institute
*	
*	Purpose:	
*	Stored Procedure return Country name for Genetic Professional
*
*
*	Change History:
*	2005		Jennifer Chen	Script Created
*	02/25/2005	Lijia Chu  return United States first	
*/

CREATE PROCEDURE dbo.usp_GetGenProfCountry

AS
BEGIN
	DECLARE	@CountryList TABLE (
		sortorder 	int identity(1,1),
		Country		Varchar(255)
		)

	DECLARE	@Country TABLE (
		sortorder 	int,
		Country		Varchar(255)
		)
	INSERT	INTO @CountryList (Country)
	SELECT distinct Country
	FROM	GenProfPracticeLocation
	ORDER BY Country

	INSERT	INTO @Country (sortorder,Country)
	SELECT	0,Country	
	FROM	@CountryList
	WHERE	Country='U.S.A.'

	INSERT	INTO @Country (sortorder,Country)
	SELECT	sortorder,Country	
	FROM	@CountryList
	WHERE	Country<>'U.S.A.'


	SELECT	Country, sortorder
	FROM	@Country
	ORDER BY sortorder	
END



GO
GRANT EXECUTE ON [dbo].[usp_GetGenProfCountry] TO [gatekeeper_role]
GO
GRANT EXECUTE ON [dbo].[usp_GetGenProfCountry] TO [websiteuser_role]
GO
