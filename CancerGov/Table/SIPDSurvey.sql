SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[SIPDSurvey]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[SIPDSurvey](
	[SurveyID] [bigint] IDENTITY(1,1) NOT NULL,
	[q1] [bit] NULL,
	[q2] [bit] NULL,
	[q3] [bit] NULL,
	[q4] [bit] NULL,
	[q5] [bit] NULL,
	[q6] [bit] NULL,
	[Comments] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_SIPDSurvey] PRIMARY KEY CLUSTERED 
(
	[SurveyID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
GRANT SELECT ON [dbo].[SIPDSurvey] TO [public]
GO
GRANT INSERT ON [dbo].[SIPDSurvey] TO [public]
GO
GRANT DELETE ON [dbo].[SIPDSurvey] TO [public]
GO
GRANT UPDATE ON [dbo].[SIPDSurvey] TO [public]
GO
GRANT SELECT ON [dbo].[SIPDSurvey] ([SurveyID]) TO [public]
GO
GRANT UPDATE ON [dbo].[SIPDSurvey] ([SurveyID]) TO [public]
GO
GRANT SELECT ON [dbo].[SIPDSurvey] ([q1]) TO [public]
GO
GRANT UPDATE ON [dbo].[SIPDSurvey] ([q1]) TO [public]
GO
GRANT SELECT ON [dbo].[SIPDSurvey] ([q2]) TO [public]
GO
GRANT UPDATE ON [dbo].[SIPDSurvey] ([q2]) TO [public]
GO
GRANT SELECT ON [dbo].[SIPDSurvey] ([q3]) TO [public]
GO
GRANT UPDATE ON [dbo].[SIPDSurvey] ([q3]) TO [public]
GO
GRANT SELECT ON [dbo].[SIPDSurvey] ([q4]) TO [public]
GO
GRANT UPDATE ON [dbo].[SIPDSurvey] ([q4]) TO [public]
GO
GRANT SELECT ON [dbo].[SIPDSurvey] ([q5]) TO [public]
GO
GRANT UPDATE ON [dbo].[SIPDSurvey] ([q5]) TO [public]
GO
GRANT SELECT ON [dbo].[SIPDSurvey] ([q6]) TO [public]
GO
GRANT UPDATE ON [dbo].[SIPDSurvey] ([q6]) TO [public]
GO
GRANT SELECT ON [dbo].[SIPDSurvey] ([Comments]) TO [public]
GO
GRANT UPDATE ON [dbo].[SIPDSurvey] ([Comments]) TO [public]
GO
