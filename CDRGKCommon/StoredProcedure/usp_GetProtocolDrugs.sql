IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetProtocolDrugs]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetProtocolDrugs]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_GetProtocolDrugs    Script Date: 9/14/2005 11:58:43 AM ******/

/*	NCI - National Cancer Institute
*	
*	Purpose:	
*
*	Objects Used:
*
*	Change History:
*	?/?/2002 	Greg Andres	Script Created
*	11/19/2002 	Alex Pidlisnyy	Change script to use vwDrug
*	11/27/2002	Greg Andres	Change script to limit query to drugs in existing protocols
*	9/20/2005	Min				CDRID
*	12/14/05    Min , Chen      remove protocoldrug join
*	12/20/05	Min, Chen use TermDrug table that are reloaded daily
*/


CREATE PROCEDURE [dbo].[usp_GetProtocolDrugs]
	@keyword	nvarchar(1000)
AS
BEGIN
	set nocount on
	
	SELECT TermID as CDRID,
		DrugName as [Name],
		DisplayName
	FROM dbo.TermDrug
	WHERE DrugName like @keyword
	ORDER BY [Name] ASC



/*
	-- Drugs
	select 	T.TermID as CDRID,
		T.PreferredName AS [Name],
		T.PreferredName AS DisplayName
	from 	Terminology AS T
		inner join dbo.TermSemanticType AS TST
			ON T.TermID = TST.TermID 
			AND TST.SemanticTypeName = 'Drug/agent'
	where T.PreferredName like @keyword
	UNION all
	select 	distinct T.TermID as CDRID,
		TON.OtherName AS [Name],
		LTRIM(RTRIM( TON.OtherName )) + ' (Other Name for: ' + LTRIM(RTRIM( T.PreferredName )) + ')' AS DisplayName	  
	from 	Terminology AS T
		inner join dbo.TermOtherName AS TON
			ON TON.TermID = T.TermID 
		inner join dbo.TermSemanticType AS TST1
			ON TON.TermID = TST1.TermID 
			AND TST1.SemanticTypeName = 'Drug/agent'
	where TON.OtherName like @keyword
	order by [Name] asc
*/
END


GO
GRANT EXECUTE ON [dbo].[usp_GetProtocolDrugs] TO [websiteuser_role]
GO
