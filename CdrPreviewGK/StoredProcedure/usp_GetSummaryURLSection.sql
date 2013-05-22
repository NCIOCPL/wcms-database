IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetSummaryURLSection]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetSummaryURLSection]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**********************************************************************************

	Object's name:	usp_GetSummaryURLSection
	Object's type:	Stored procedure
	Purpose:	Get real URL
	
	Change History:
	2/22/2007 	Jay He

**********************************************************************************/


CREATE PROCEDURE dbo.usp_GetSummaryURLSection
       	@SummaryID uniqueidentifier = null,
	@SectionID varchar(200)
AS

	Declare @PageSection  varchar(200),
		@SummarySectionID uniqueidentifier


	Select @PageSection = @SectionID 

	if  (@SummaryID is not null)
	BEGIN

		select @SummarySectionID = SummarySectionID from dbo.SummarySection 
		where summaryGUID =@SummaryID and SectionID = @SectionID

		select  @PageSection =  dbo.udf_GetSummaryTopLevelSectionIDWithTable(@SummarySectionID)
		
		
		if (@PageSection is null)
			Select @PageSection = @SectionID 
	END

	SELECT	@PageSection as pagesection

GO
GRANT EXECUTE ON [dbo].[usp_GetSummaryURLSection] TO [webSiteUser_role]
GO
