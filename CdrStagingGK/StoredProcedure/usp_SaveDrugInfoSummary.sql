IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveDrugInfoSummary]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveDrugInfoSummary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*	NCI - National Cancer Institute
*	
*	Purpose:	
*
*	Objects Used:
*
*	Change History:

*	To Do List:
*
*/
CREATE PROCEDURE dbo.usp_SaveDrugInfoSummary
	(
		@DrugInfoSummaryID int,
		@Title varchar(255),
		@Description varchar(1500),
		@PrettyURL varchar(255),
		@HTMLData text,
		@DateFirstPublished datetime,
		@DateLastModified datetime,
		@TerminologyLink int,
		@NCIViewID uniqueidentifier,
		@UpdateUserID varchar(50),
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	
	insert into dbo.DrugInfoSummary
		(	DrugInfoSummaryID,
			Title,
			Description,
			PrettyURL,
			HTMLData,
			DateFirstPublished,
			DateLastModified,
			TerminologyLink,
			NCIViewID,
			UpdateUserID,
			UpdateDate
			)
	values(
		@DrugInfoSummaryID,
		@Title,
		@Description,
		@PrettyURL,
		@HTMLData,
		@DateFirstPublished,
		@DateLastModified,
		@TerminologyLink,
		@NCIViewID,
		@UpdateUserID,
		@UpdateDate)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @DrugInfoSummaryID,'DrugInfoSummary')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.DrugInfoSummary table Saved for ID: '+ convert(varchar(50), @DrugInfoSummaryID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveDrugInfoSummary] TO [Gatekeeper_role]
GO
