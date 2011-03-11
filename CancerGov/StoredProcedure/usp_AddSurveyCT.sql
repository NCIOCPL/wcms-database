IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_AddSurveyCT]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_AddSurveyCT]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.usp_AddSurvey    Script Date: 10/3/2002 10:45:48 AM ******/
CREATE PROCEDURE dbo.usp_AddSurveyCT
(
	@SurveyID	uniqueidentifier,
	@SetID		int,
	@Question1  	varchar(50) ,
	@Question2  	varchar(1000),
	@Question3  	varchar(50),
	@Question4  	varchar(200),
	@Question5  	varchar(50),
	@UpdateUserIP		varchar(50)
)
AS
	SET NOCOUNT OFF;

	INSERT into SurveyCT
	(SurveyID, SetID,	Question1, 	Question2, 	Question3, 	Question4, 	Question5, 	UpdateUserIP)   
	values
	(@SurveyID, @SetID,	@Question1,	@Question2, 	@Question3, 	@Question4, 	@Question5, 	@UpdateUserIP)
GO
