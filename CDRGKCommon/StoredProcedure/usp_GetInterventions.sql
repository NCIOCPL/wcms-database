IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetInterventions]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetInterventions]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_GetInterventions    Script Date: 6/29/2005 2:37:41 PM ******/




/**********************************************************************************

	Object's name:	usp_GetInterventions
	Object's type:	store proc
	Purpose:	need stored proc that can search for all drug terms that match 'Term%':
			by search word that matches against prefered and/or all othernames.  

			Search returns a list of:
			1) CDRID
			2) prefered name
			3) othernames that match

**********************************************************************************/	

CREATE PROCEDURE dbo.usp_GetInterventions
	(
	@Match	nvarchar(2000) = '%'
)
AS
BEGIN
	
set nocount on
select 	distinct T.TermID as CDRID,
	T.PreferredName as Name,
	T.PreferredName  as displayname
from 	dbo.Terminology AS T
	inner join dbo.TermSemanticType AS TST
		ON T.TermID = TST.TermID 
	inner join protocolmodality m on m.modalityid = t.termid	
where TST.SemanticTypeName = 'Intervention or procedure'
and T.PreferredName like @match  + '%'
union all
select 	Distinct T.TermID as CDRID,
	TON.OtherName as Name,
	LTRIM(RTRIM( TON.OtherName )) + ' (Other Name for: ' + LTRIM(RTRIM( T.PreferredName )) + ')' AS 'DisplayName'	  
from 	dbo.Terminology AS T
	inner join dbo.TermOtherName AS TON
		ON TON.TermID = T.TermID 
	inner join dbo.TermSemanticType AS TST1
		ON TON.TermID = TST1.TermID 
		INNER JOIN dbo.Protocolmodality AS m
		ON T.TermID = m.modalityID
where  TST1.SemanticTypeName = 'Intervention or procedure'
and TON.OtherName like @match  + '%'
order by Name

END

GO
GRANT EXECUTE ON [dbo].[usp_GetInterventions] TO [websiteuser_role]
GO
