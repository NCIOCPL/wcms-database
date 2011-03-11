IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveSummary]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveSummary]
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
*
*  ShortTitle Save added 2007 Sept. Gao
*	To Do List:
*
*/
CREATE PROCEDURE dbo.usp_SaveSummary
	(
		@SummaryID int, 
		@Type varchar(50), 
		@Audience varchar(50), 
		@Language varchar(50), 
		@Title varchar(255), 
		@ShortTitle varchar(64),  --gao
		@UpdateUserID varchar(50), 
		@Description varchar(1500), 
		@PrettyURL varchar(250), 
		@replacementDocumentID int,
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	
	insert into dbo.Summary
		(SummaryID,
		Type,
		Audience,
		Language,
		Title,
		ShortTitle,
		UpdateUserID,
		Description,
		PrettyURL,
		replacementDocumentID,
		UpdateDate)
	values(
		@SummaryID,
		@Type,
		@Audience,
		@Language,
		@Title,
		@shortTitle,
		@UpdateUserID,
		@Description,
		@PrettyURL,
		@replacementDocumentID,
		@UpdateDate)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @SummaryID,'Summary')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.Summary table Saved for ID: '+ convert(varchar(50), @SummaryID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveSummary] TO [Gatekeeper_role]
GO
