IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetSummaryInfo]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetSummaryInfo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**********************************************************************************

	Object's name:	usp_GetSummaryInfo
	Object's type:	Stored procedure
	Purpose:	
	
	Change History:
	

**********************************************************************************/


CREATE PROCEDURE dbo.usp_GetSummaryInfo
	@SummaryID	int
AS
set nocount on

DECLARE @SummaryRelations TABLE
	(SummaryID int,
	 type	   varchar(30),
	 RelatedDocumentGUID UniqueIdentifier
	)

--Get DocumentGUID of Patient or HP version 

INSERT INTO @SummaryRelations
	SELECT	summaryid,
		'VersionOf',
		DocumentGUID
	FROM	SummaryRelations r
		INNER JOIN Document d
			ON r.RelatedSummaryID = d.DocumentID
	WHERE	r.SummaryID =@summaryID
	AND	r.RelationType='PatientVersionOf'

IF @@rowcount=0
	INSERT INTO @SummaryRelations
	SELECT	r.RelatedSummaryID,
		'VersionOf',
		DocumentGUID
	FROM	SummaryRelations r
		INNER JOIN Document d
			ON r.SummaryID = d.DocumentID
	WHERE	r.RelatedSummaryID =@summaryID
	AND	r.RelationType='PatientVersionOf'

--Get DocumentGUID of OtherLanguage 

INSERT INTO @SummaryRelations
	SELECT	summaryid,
		'OtherLanguage',
		DocumentGUID
	FROM	SummaryRelations r
		INNER JOIN Document d
			ON r.RelatedSummaryID = d.DocumentID
	WHERE	r.SummaryID =@summaryID
	AND	r.RelationType='SpanishTranslationOf'


IF @@rowcount=0
	INSERT INTO @SummaryRelations
	SELECT	r.RelatedSummaryID,
		'OtherLanguage',
		DocumentGUID
	FROM	SummaryRelations r
		INNER JOIN Document d
			ON r.SummaryID = d.DocumentID
	WHERE	r.RelatedSummaryID =@summaryID
	AND	r.RelationType='SpanishTranslationOf'

	

SELECT 	d.DocumentID, 
	d.DocumentGUID, 
	d.IsActive, 
	d.Status, 
	d.DateLastModified, 
	s.Type, 
	s.Audience, 
	s.Language, 
	s.Title,
	s.ShortTitle,
	r1.RelatedDocumentGUID	RelatedDocumentGUID,
	r2.RelatedDocumentGUID	OtherLanguageDocumentGUID,
	d1.documentGUID as replacementforDocumentGUID,
	s.Description,
	s.PrettyURL
FROM 	dbo.Summary s 
	INNER JOIN Document d
		ON s.SummaryID = d.DocumentID
	LEFT OUTER JOIN @SummaryRelations r1
		ON s.SummaryID=r1.SummaryID
		AND	r1.Type= 'VersionOf'
	LEFT OUTER JOIN @SummaryRelations r2
		ON s.SummaryID=r2.SummaryID
		AND	r2.Type= 'OtherLanguage'
	LEFT outer join dbo.document d1
		on d1.documentid = s.replacementDocumentID
WHERE 	d.DocumentID = @summaryID


GO
GRANT EXECUTE ON [dbo].[usp_GetSummaryInfo] TO [gatekeeper_role]
GO
