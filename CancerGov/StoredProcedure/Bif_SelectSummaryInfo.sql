IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Bif_SelectSummaryInfo]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[Bif_SelectSummaryInfo]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE dbo.Bif_SelectSummaryInfo
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
GRANT EXECUTE ON [dbo].[Bif_SelectSummaryInfo] TO [websiteuser_role]
GO
