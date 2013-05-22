IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetViewSummary]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetViewSummary]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE usp_GetViewSummary
	(
	@ViewId		uniqueidentifier = null,
	@SummaryId		varchar(9) = null
	)
AS
BEGIN

IF @ViewId IS NOT NULL
BEGIN
	SELECT v.NCIViewId, 
		v.Title, 
		v.ShortTitle, 
		v.Description, 
		v.MetaTitle, 
		v.MetaDescription, 
		v.MetaKeyword, 
		s.SummaryId, 
		s.SummaryType, 
		s.PatientDataSize, 
		s.PatientData, 
		s.HPDataSize, 
		s.HPData, 
		ns.[Name] AS SectionName,
		ns.SectionHomeViewId
	FROM 	NCIView v INNER JOIN (ViewObjects vo INNER JOIN Summary s ON vo.ObjectId =  s.SummaryId) 
		ON v.NCIViewId = vo.NCIViewId LEFT OUTER JOIN NCISection ns 
		ON v.NCISectionId = ns.NCISectionId
	WHERE v.NCIViewId = @ViewId
END
ELSE
BEGIN
	SELECT v.NCIViewId, 
		v.Title, 
		v.ShortTitle, 
		v.Description, 
		v.MetaTitle, 
		v.MetaDescription, 
		v.MetaKeyword, 
		s.SummaryId, 
		s.SummaryType, 
		s.PatientDataSize, 
		s.PatientData, 
		s.HPDataSize, 
		s.HPData, 
		ns.[Name] AS SectionName,
		ns.SectionHomeViewId
	FROM 	NCIView v INNER JOIN (ViewObjects vo INNER JOIN Summary s ON vo.ObjectId =  s.SummaryId) 
		ON v.NCIViewId = vo.NCIViewId LEFT OUTER JOIN NCISection ns 
		ON v.NCISectionId = ns.NCISectionId
	WHERE s.SourceId = @SummaryId
END

END
GO
