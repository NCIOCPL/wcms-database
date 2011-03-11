IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveGlossaryTermDefinitionDictionary]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveGlossaryTermDefinitionDictionary]
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
CREATE PROCEDURE dbo.usp_SaveGlossaryTermDefinitionDictionary
	(
		@GlossaryTermDefinitionID int, 
		@Dictionary varchar(500), 
		@UpdateUserID varchar(50), 
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	
	insert into dbo.GlossaryTermDefinitionDictionary
		(	GlossaryTermDefinitionID,
			Dictionary,
			UpdateUserID,
			UpdateDate)
	values(
		@GlossaryTermDefinitionID,
		@Dictionary,
		@UpdateUserID,
		@UpdateDate)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @GlossaryTermDefinitionID,'GlossaryTermDefinitionDictionary')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.GlossaryTermDefinitionDictionary table Saved for ID: '+ convert(varchar(50), @GlossaryTermDefinitionID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveGlossaryTermDefinitionDictionary] TO [Gatekeeper_role]
GO
