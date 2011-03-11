IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateSurvey]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateSurvey]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_AddSurvey    Script Date: 10/5/2001 10:45:48 AM ******/
CREATE PROCEDURE dbo.usp_UpdateSurvey
(
	@Question3A  	varchar(255),
	@Question4A	varchar(255),
	@Question5	varchar(2000),
	@Question6	varchar(2000),
	@Question7A	varchar(50),
	@Question7B	varchar(50),
	@Question7C	varchar(50),
	@Question7D	varchar(50),
	@Question8	varchar(255),
	@Question9A	varchar(50),
	@Question9B	varchar(50),
	@Question9C	varchar(50),
	@Question10	varchar(2000),
	@Question11	varchar(2000),
	@Question12	varchar(50),
	@Question13	varchar(50),
	@Question14	varchar(255),
	@SurveyID	uniqueidentifier
)
AS
	SET NOCOUNT OFF;

	Update Survey
	set 	Question3A	=@Question3A,
		Question4A	=@Question4A,
		Question5	=@Question5,
		Question6	= @Question6,
		Question7A	= @Question7A, 
		Question7B	=@Question7B,
		Question7C	=@Question7C,
		Question7D	=@Question7D,
		Question8	=  @Question8,
		Question9A	= @Question9A,
		Question9B	=@Question9B, 
		Question9C	=@Question9C,
		Question10	= @Question10, 
		Question11	=@Question11,
		Question12	=@Question12,
		Question13	=@Question13, 
		Question14	=@Question14
	WHERE SurveyID = @SurveyID
GO
