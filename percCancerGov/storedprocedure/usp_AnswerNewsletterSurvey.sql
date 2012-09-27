IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_AnswerNewsletterSurvey]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_AnswerNewsletterSurvey]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************
* Name		: usp_AnswerNewsletterSurvey
* Purpose	: This writes the answers of the 
* Author	: BP
* Date		: 01/25/2007
* Returns	: Table
* Usage		: exec usp_AnswerNewsletterSurvey @SurveyID='21D177EB-19D0-46EC-BFDC-5BC089568963',
				@Question1 = 'Colleague|;Association/organization|Blah',
				@Question2 = 'Other|Developer',	
				@languageCode = 'en'

* Changes	: 
**************************************************************************************************/
CREATE PROCEDURE [dbo].[usp_AnswerNewsletterSurvey]
(
	@SurveyID uniqueidentifier,
	@Question1 varchar(4000),
	@Question2 varchar(4000),
	@languageCode nvarchar(2)
)
AS
BEGIN

	DECLARE @Responses TABLE (
		QuestionNumber int,
		QuestionAnswer varchar(500),
		AdditionalTextValue varchar(500)
	)

	DECLARE @RespondantID uniqueidentifier
	SET @RespondantID = newid()

	INSERT INTO @Responses
	(QuestionNumber, QuestionAnswer, AdditionalTextValue)
	SELECT 
		1 as QuestionNumber,
		[Key] as QuestionAnswer,
		Value as AdditionalTextValue
	FROM dbo.udf_HashtableToTable (@Question1, '|', ';')

	INSERT INTO @Responses
	(QuestionNumber, QuestionAnswer, AdditionalTextValue)
	SELECT 
		2 as QuestionNumber,
		[Key] as QuestionAnswer,
		Value as AdditionalTextValue
	FROM dbo.udf_HashtableToTable (@Question2, '|', ';')

	INSERT INTO NewsletterSurvey
	SELECT 
		@SurveyID as SurveyID,
		@RespondantID as RespondantID,
		QuestionNumber,
		QuestionAnswer,
		AdditionalTextValue,
		GetDate() as UpdateDate,
		@languageCode as languageCode
	FROM @Responses

END

GO
GRANT EXECUTE ON [dbo].[usp_AnswerNewsletterSurvey] TO [websiteuser_role]
GO
