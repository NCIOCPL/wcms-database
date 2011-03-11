IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetDrugInfoSummary]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetDrugInfoSummary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**********************************************************************************

	Object's name:	usp_GetDrugInfoSummary
	Object's type:	Stored procedure
	Purpose:	
	
	Change History:


**********************************************************************************/


CREATE PROCEDURE dbo.usp_GetDrugInfoSummary
@DrugInfoSummaryID int
AS
SELECT     Title, Description, PrettyURL, documentGUID,
           HTMLData, DateFirstPublished, ds.DateLastModified, 
           TerminologyLink
      FROM dbo.DrugInfoSummary ds inner join dbo.document d on d.documentid= ds.drugInfoSummaryID
     WHERE DrugInfoSummaryID =  @DrugInfoSummaryID
	
GO
GRANT EXECUTE ON [dbo].[usp_GetDrugInfoSummary] TO [Gatekeeper_role]
GO
