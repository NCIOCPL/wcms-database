IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_AddSurveyGeneral]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_AddSurveyGeneral]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.usp_AddSurvey    Script Date: 10/3/2002 10:45:48 AM ******/
CREATE PROCEDURE dbo.usp_AddSurveyGeneral
(
	@SetID		int,
	@Question4  	varchar(200),
	@Question5  	varchar(50),
	@Question6	VarChar(200 ),
	@Question7	VarChar(50 ),
	@Question8		VarChar(50),
	@Question9		VarChar(50),
	@Question10A		VarChar(50),
	@Question10B		VarChar(50),
	@Question10C		VarChar(50),
	@Question10D		VarChar(50),
	@Question10E		VarChar(50),
	@Question10F		VarChar(50),
	@Question10G		VarChar(50),
	@Question10H		VarChar(50),
	@Question11   		VarChar(1000),
	@Question12  		VarChar(50),
	@Question13   		VarChar(1000),				
	@UpdateUserIP		varchar(50)
)
AS
	SET NOCOUNT OFF;

	INSERT into SurveyCT
	(SetID,	Question4, Question5, Question6, Question7, Question8, Question9,Question10A, Question10B, Question10C, Question10D, Question10E,Question10F, Question10G, Question10H,Question11,Question12,Question13, UpdateUserIP)   
	values
	(@SetID,
	@Question4, 
	@Question5, 
	@Question6, 
	@Question7, 
	@Question8, 
	@Question9,
	@Question10A, 
	@Question10B, 
	@Question10C, 
	@Question10D, 
	@Question10E,
	@Question10F, 
	@Question10G, 
	@Question10H,
	@Question11,
	@Question12,
	@Question13, 
	@UpdateUserIP)
GO
