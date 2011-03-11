IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetAnyCitation]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetAnyCitation]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.usp_ProtocolSearch    Script Date: 2/14/2002 2:02:50 PM ******/
/*	NCI - National Cancer Institute
*	
*	Purpose:	
*	Stored procedure perform Clinical Trial Search 
*
*	Objects Used:
*	CancerGov..ProtocolRelatedTerm - table
*
*	Change History:
*	?/?/2001	Greg Andres	Script Created
*	3/1/2002 	Alex Pidlisnyy	 - Return Correct Publication Type
*					- add @ParentCitationInfo
*
*/

CREATE PROCEDURE usp_GetAnyCitation
	(
	@SourceID	int,
	@Type		varchar(50) = null,
	@CitationID	uniqueidentifier = null
	)
AS
BEGIN
	DECLARE @ParentCitationInfo varchar(255)	
	
	IF (NULLIF(@Type, '') IS NULL OR @CitationID IS NULL)
	BEGIN
		SELECT @Type = t.[Name], 
			@CitationId = c.CitedEntityID 
		FROM 	Citation c INNER JOIN Type t 
			ON c.Type = t.TypeID 
		WHERE c.SourceID = @SourceId
	END

	IF @Type = 'literature'
	BEGIN
	
		SELECT @ParentCitationInfo = SearchTitle
		FROM	LiteratureCitation
		WHERE LiteratureCitationID IN
			(
			SELECT	ParentLiteratureCitationID
			FROM		LiteratureCitation
			WHERE 	LiteratureCitationID = @CitationId
			)

		SELECT LC.SearchTitle AS Title, 
			LC.Author, 
			('  ' + @ParentCitationInfo + '  ' + LC.PublicationInfo) AS 'PublicationInfo',  
			LCA.Abstract,
			LC.CancerLitID, 
			(SELECT [Name] FROM Type WHERE TypeID = LC.Type) AS Pub_Type, 
			@Type AS CitationType, 
			LC.SourceID
		FROM 	LiteratureCitation AS LC LEFT OUTER JOIN LiteratureCitationAbstract AS LCA
			ON LC.LiteratureCitationID = LCA.LiteratureCitationID
		WHERE LC.LiteratureCitationID = @CitationId
	END
	ELSE
	BEGIN
		IF @Type = 'protocol'
			BEGIN
				SELECT t.[Name], 
					pd.Data, 
					p.Title, 
					@Type AS Pub_Type,
					@Type AS CitationType
				FROM 	Protocol p INNER JOIN ProtocolData pd 
					ON p.ProtocolId = pd.ProtocolId 
					INNER JOIN Type t 
					ON pd.Type = t.TypeID 
				WHERE pd.ProtocolId = @CitationId 
					AND t.[Name] IN ('abstract', 'objectives', 'entry criteria')
			END
		ELSE
			BEGIN
				IF @Type = 'database'
					BEGIN
						SELECT *, @Type As CitationType
						FROM DatabaseCitation
						WHERE DatabaseCitationID = @CitationId
					END
			END
	END
END
GO
