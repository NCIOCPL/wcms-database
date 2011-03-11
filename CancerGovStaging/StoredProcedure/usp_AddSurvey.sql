IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_AddSurvey]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_AddSurvey]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_AddSurvey    Script Date: 10/5/2001 10:45:48 AM ******/
CREATE PROCEDURE dbo.usp_AddSurvey
(
	@SurveyID	uniqueidentifier,
	@Question1  	varchar(255) ,
	@Question2  	varchar(255),
	@Question3  	varchar(255),
	@Question4  	varchar(2000),
	@UpdateUserIP		varchar(50)
)
AS
	SET NOCOUNT OFF;

	INSERT into Survey
	(SurveyID,	Question1, 	Question2, 	Question3, 	Question4, 	UpdateUserIP)   
	values
	(@SurveyID,	@Question1,	@Question2, 	@Question3, 	@Question4, 	@UpdateUserIP)
GO
