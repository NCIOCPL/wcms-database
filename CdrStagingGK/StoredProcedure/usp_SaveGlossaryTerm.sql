IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveGlossaryTerm]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveGlossaryTerm]
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
CREATE PROCEDURE dbo.usp_SaveGlossaryTerm
	(
		@GlossaryTermID int, 
		@TermName varchar(2000), 
		@TermPronunciation varchar(2000), 
		@SpanishTermName varchar(2000), 
		@UpdateUserID varchar(50), 
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	
	insert into dbo.glossaryTerm
		(GlossaryTermID,
		TermName,
		TermPronunciation,
		SpanishTermName,
		updateUserid,
		UpdateDate)
	values(
		@GlossaryTermID,
		@TermName,
		@TermPronunciation,
		@SpanishTermName,
		@updateUserid,
		@UpdateDate)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @GlossaryTermID,'GlossaryTerm')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.GlossaryTerm table Saved for ID: '+ convert(varchar(50), @GlossaryTermID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveGlossaryTerm] TO [Gatekeeper_role]
GO
