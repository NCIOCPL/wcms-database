IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetDefinition]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetDefinition]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*	NCI - National Cancer Institute
*	
*	Purpose:	
*	Stored Procedure return Glossary Term information ( Name,  Pronunciation, Definition )
*
*	Objects Used:
*	Glossary - table
*
*	Change History:
*	2001		Greg Andres	Script Created
*	1/18/2002 	Alex Pidlisnyy	Add functionality to work with uniqueidentifier or integer IDs
*	1/18/2002 	Alex Pidlisnyy	Eliminate spaces between words in the term to be able get correct result 
*					if more spaces provided in @Term variable.
*
*/

CREATE PROCEDURE usp_GetDefinition
	(
	@Term		varchar(255) 	= null,
	@ID		varchar(50) 	= null
	)
AS
BEGIN
	IF @Term <> Null
	BEGIN
		-- Search by Glossary Name	
		SELECT GlossaryID, 
			[Name], 
			Pronunciation, 
			Definition 
		FROM Glossary
		WHERE REPLACE( [Name], ' ', '')  = REPLACE( @Term, ' ', '') 

	END
	ELSE BEGIN
		IF LEN(@ID) = 36
		BEGIN
			-- Search by GlossaryID  (uniqueidentifier)
			SELECT GlossaryID, 
				[Name], 
				Pronunciation, 
				Definition 
			
			FROM Glossary
			WHERE GlossaryID = convert( uniqueidentifier, @ID)
		END
		ELSE BEGIN
			-- Search by PDQ GlossaryID (int)
			SELECT GlossaryID, 
				[Name], 
				Pronunciation, 
				Definition 
			FROM 	Glossary
			WHERE SourceID = convert( int, @ID)
		END
	END
END
GO
