IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveGlossaryTermDefinitionAudience]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveGlossaryTermDefinitionAudience]
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
CREATE PROCEDURE dbo.usp_SaveGlossaryTermDefinitionAudience
	(
		@GlossaryTermDefinitionID int, 
		@Audience varchar(500), 
		@UpdateUserID varchar(50), 
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	
	insert into dbo.GlossaryTermDefinitionAudience
		(GlossaryTermDefinitionID,
			Audience,
			UpdateUserID,
			UpdateDate)
	values(
		@GlossaryTermDefinitionID,
		@Audience,
		@UpdateUserID,
		@UpdateDate)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @GlossaryTermDefinitionID,'GlossaryTermDefinitionAudience')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.GlossaryTermDefinitionAudience table Saved for ID: '+ convert(varchar(50), @GlossaryTermDefinitionID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveGlossaryTermDefinitionAudience] TO [Gatekeeper_role]
GO
