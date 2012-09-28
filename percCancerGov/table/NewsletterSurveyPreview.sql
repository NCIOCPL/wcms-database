SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = 
OBJECT_ID(N'[dbo].[NewsletterSurveyPreview]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[NewsletterSurveyPreview](
	[SurveyID] [uniqueidentifier] NOT NULL,
	[RespondantID] [uniqueidentifier] NOT NULL,
	[QuestionNumber] [int] NOT NULL,
	[QuestionAnswer] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AdditionalTextValue] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[updatedate] [datetime] NULL CONSTRAINT [DF_NewsletterSurveyPreview_updateDate]  DEFAULT (getdate()),
	languageCode nvarchar(2) NOT NULL DEFAULT('en') 
) ON [PRIMARY]
END
GO
