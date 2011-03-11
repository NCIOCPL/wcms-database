IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetSummary]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetSummary]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE usp_GetSummary
	(
	@SummaryId		uniqueidentifier
	)
AS
BEGIN
	SELECT SummaryId, 
		SummaryType, 
		PatientDataSize, 
		PatientData, 
		HPDataSize, 
		HPData
	FROM 	Summary
	WHERE SummaryId = @SummaryId
END

GO
