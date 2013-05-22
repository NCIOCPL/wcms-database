IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateSurveyCT]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateSurveyCT]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.usp_AddSurvey    Script Date: 10/3/2002 10:45:48 AM ******/
CREATE PROCEDURE dbo.usp_UpdateSurveyCT
(
	@Question6  	varchar(200),
	@Question7	varchar(50),
	@Question8	varchar(50),
	@Question9	varchar(50),
	@Question10A	varchar(50),
	@Question10B	varchar(50),
	@Question10C	varchar(50),
	@Question10D	varchar(50),
	@Question10E	varchar(50),
	@Question10F	varchar(50),
	@Question10G	varchar(50),
	@Question10H	varchar(50),
	@Question11	varchar(1000),
	@Question12	varchar(50),
	@Question13	varchar(1000),
	@SurveyID	uniqueidentifier
)
AS
	SET NOCOUNT OFF;

	Update SurveyCT
	set 	Question6	=@Question6,
		Question7	=@Question7,
		Question8	=@Question8,
		Question9	= @Question9,
		Question10A	= @Question10A, 
		Question10B	=@Question10B,
		Question10C	=@Question10C,
		Question10D	=@Question10D,
		Question10E	=  @Question10E,
		Question10F	= @Question10F,
		Question10G	=@Question10G, 
		Question10H	=@Question10H,
		Question11	=@Question11,
		Question12	=@Question12,
		Question13	=@Question13
	WHERE SurveyID = @SurveyID
GO
