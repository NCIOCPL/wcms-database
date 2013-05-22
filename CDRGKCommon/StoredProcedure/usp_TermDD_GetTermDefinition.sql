IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_TermDD_GetTermDefinition]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_TermDD_GetTermDefinition]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO



/**********************************************************************************

	Object's name:	usp_TermDD_GetTermDefinition
	Object's type:	store proc
	Purpose:	To search the Term Drug Dictionary by string match and also return previous and next <num> matches
	Author:		5/4/2005	Chen Ling
	Change History:
	5/10/2005 	Chen Ling	Updated script to use view
	8/29/2006	Vadim Provotorov  Added PrettyURL extraction

**********************************************************************************/	

CREATE PROCEDURE dbo.usp_TermDD_GetTermDefinition
	(
	@TermID	int
	)
AS
BEGIN

	IF EXISTS (SELECT 1 FROM vwTermDrugDictionary WHERE TermID = @TermID)
	BEGIN	
		SELECT PreferredName, DefinitionHTML, PrettyURL
		FROM vwTermDrugDictionary
		WHERE TermID = @TermID

		SELECT tons.DisplayName, ton.OtherName
		FROM TermOtherName ton, TermOtherNameType tons
		WHERE ton.TermID =  @TermID
		AND ton.OtherNameType = tons.OtherNameType
		ORDER BY tons.Priority,  ton.OtherName
	END
END
GO


GO
GRANT EXECUTE ON [dbo].[usp_TermDD_GetTermDefinition] TO [websiteuser_role]
GO
