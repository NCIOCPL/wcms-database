IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveSummaryRelations]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveSummaryRelations]
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
CREATE PROCEDURE dbo.usp_SaveSummaryRelations
	(
		@SummaryID int, 
		@RelatedSummaryID int, 
		@RelationType varchar(50), 
		@UpdateUserID varchar(50), 
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	
	insert into dbo.SummaryRelations
		(SummaryID,
			RelatedSummaryID,
			RelationType,
			UpdateUserID,
		UpdateDate)
	values(
		@SummaryID,
		@RelatedSummaryID,
		@RelationType,
		@UpdateUserID,
		@UpdateDate)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @SummaryID,'SummaryRelations')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.SummaryRelations table Saved for ID: '+ convert(varchar(50), @SummaryID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveSummaryRelations] TO [Gatekeeper_role]
GO
