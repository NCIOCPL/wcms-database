IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetGlossary]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetGlossary]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE usp_GetGlossary
	(
	@Criteria	varchar(6) = null	
	)
AS

IF @Criteria IS NULL
	BEGIN
		SELECT GlossaryID, [Name], Pronunciation, Definition
		FROM Glossary 
	END
ELSE
	BEGIN
		SELECT GlossaryID, [Name], Pronunciation, Definition
		FROM Glossary 
		WHERE [Name] LIKE @Criteria
	END
GO
