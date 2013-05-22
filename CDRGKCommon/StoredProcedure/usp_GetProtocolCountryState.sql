IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetProtocolCountryState]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetProtocolCountryState]
GO
/*	NCI - National Cancer Institute
*	
*	File Name:	
*	usp_GetProtocolCountryState
*
*	Objects Used:
*
*	Change History:
*
*	To Do:
*
*/
CREATE PROCEDURE [dbo].[usp_GetProtocolCountryState]

AS
BEGIN
	DECLARE @TABLE TABLE 
	(
		Country varchar(255) null, 
		[State] varchar(100) null, 
		[Name] varchar(50) null, 
		Value varchar(512) null
	)
	
	--Get US state abbreviations
	INSERT @TABLE
	Select 	DISTINCT 
		pci.Country, 
		pci.State AS State, 
		pci.StateFullName AS [Name], 
		pci.Country + '|' + pci.State AS [Value] 
	
	From 
	dbo.protocoltrialsite pci (NOLOCK) 
INNER JOIN dbo.PoliticalSubUnit psu (NOLOCK)
		ON pci.state = psu.shortname 
		AND pci.Country = psu.CountryName
		AND pci.stateFullName IS NOT NULL 
	Where pci.Country = 'U.S.A.'
	
	
	--Get International Countries with full state names
	INSERT @TABLE
	Select 	DISTINCT 
		pci.Country, 
		psu.FullName AS State, 
		pci.Country + ' - ' + psu.FullName AS [Name], 
		pci.Country + '|' + psu.FullName AS [Value] 
	From dbo.protocoltrialsite pci (NOLOCK) 
 INNER JOIN dbo.PoliticalSubUnit psu (NOLOCK)
		ON pci.state = psu.shortname 
		AND pci.Country = psu.CountryName
		AND pci.stateFullName IS NOT NULL 
	Where pci.Country <> 'U.S.A.'
	
	
	--Get International Countries with no states
	INSERT @TABLE
	Select 	DISTINCT
		pci.Country, 
		NULL AS State, 
		pci.Country AS [Name], 
		pci.Country + '|' AS [Value] 
	From dbo.protocoltrialsite pci (NOLOCK) 
	WHERE pci.country <> 'U.S.A.'
	
	
	SELECT
	DISTINCT Country, State, [Name], [Value]
	from @TABLE
	order by Country, [Name]

END 

GO
GRANT EXECUTE ON [dbo].[usp_GetProtocolCountryState] TO [websiteuser_role]
GO
