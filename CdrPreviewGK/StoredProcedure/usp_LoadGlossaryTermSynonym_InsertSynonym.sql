IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_LoadGlossaryTermSynonym_InsertSynonym]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_LoadGlossaryTermSynonym_InsertSynonym]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.usp_LoadGlossaryTermSynonym_InsertSynonym    Script Date: 12/21/2005 4:21:11 PM ******/

/*	NCI - National Cancer Institute
*	
*	Purpose:	
*
*	Objects Used:
*
*	Change History:
*	12/08/2005	Chen Ling				Script Created
*
*	To Do List:
*
*/


CREATE PROCEDURE dbo.usp_LoadGlossaryTermSynonym_InsertSynonym
(
	@GlossaryTermID	int,
	@TermName		nvarchar(1000),
	@Synonym		nvarchar(1000)
)

AS
BEGIN
	Set nocount on

	INSERT INTO dbo.GlossaryTermSynonym
		(GlossaryTermID, TermName, Synonym)
	VALUES
		(@GlossaryTermID, @TermName, @Synonym)
END


GO
GRANT EXECUTE ON [dbo].[usp_LoadGlossaryTermSynonym_InsertSynonym] TO [Gatekeeper_role]
GO
