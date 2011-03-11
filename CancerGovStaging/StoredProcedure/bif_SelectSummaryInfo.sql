IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[bif_SelectSummaryInfo]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[bif_SelectSummaryInfo]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE dbo.bif_SelectSummaryInfo
(
	@SummaryID as uniqueidentifier
)
AS
	SET NOCOUNT ON;
SELECT SummaryID, 
	SummaryType, 
	Name, 
	PatientDataSize, 
	PatientData, 
	HPDataSize, 
	HPData 
FROM Summary 
WHERE (SummaryID = @SummaryID)
GO
