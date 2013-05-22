IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_getDrugInfoSummaryURL]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_getDrugInfoSummaryURL]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[usp_getDrugInfoSummaryURL] 
AS
BEGIN	
	SET NOCOUNT ON
	select prettyurl from dbo.druginfosummary	
	
END

GO
GRANT EXECUTE ON [dbo].[usp_getDrugInfoSummaryURL] TO [webadminuser_role]
GO
