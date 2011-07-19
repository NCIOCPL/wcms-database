IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveGlossaryTermDefinition]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveGlossaryTermDefinition]
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
*	Change History: Prasad(06/03) Added a new column to support audio media html.

*	To Do List:
*
*/
CREATE PROCEDURE [dbo].[usp_SaveGlossaryTermDefinition]
	(   @GlossaryTermDefinitionID int output,
		@GlossaryTermID int, 
		@DefinitionText varchar(3900), 
		@DefinitionHTML varchar(3900), 
		@Language varchar(20), 
		@UpdateUserID varchar(50), 
		@MediaHTML ntext, 
		@AudioMediaHTML ntext, 
		@RelatedInformationHtml ntext, 
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	declare @r int
	declare @updateDate datetime
	set @updatedate = getdate()	
	
	insert into dbo.GlossaryTermDefinition
		(	GlossaryTermID,
			DefinitionText,
			DefinitionHTML,
			[Language],
			UpdateUserID,
			MediaHTML,
			AudioMediaHTML,
			RelatedInformationHtml, 
			UpdateDate)
	values(
		@GlossaryTermID,
		@DefinitionText,
		@DefinitionHTML,
		@Language,
		@UpdateUserID,
		@MediaHTML,
		@AudioMediaHTML,
		@RelatedInformationHtml,
		@UpdateDate)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @GlossaryTermID,'GlossaryTermDefinition')
		RETURN 69990
	END 
	set @GlossaryTermDefinitionID = scope_identity()

	if @isDebug =1  PRINT  '  ***       - dbo.GlossaryTermDefinition table Saved for ID: '+ convert(varchar(50), @GlossaryTermID)
			
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveGlossaryTermDefinition] TO [Gatekeeper_role]
GO
