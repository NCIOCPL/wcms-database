IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveTermDefinition]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveTermDefinition]
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
CREATE PROCEDURE dbo.usp_SaveTermDefinition
	(
		@TermID int, 
		@Definition varchar(1000), 
		@DefinitionType varchar(50), 
		@Comment varchar(255), 
		@UpdateUserID varchar(50), 
		@DefinitionHTML nvarchar(2000), 
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	
	insert into dbo.TermDefinition
		(	TermID,
			Definition,
			DefinitionType,
			Comment,
			UpdateUserID,
			DefinitionHTML,
		UpdateDate)
	values(
		@TermID,
		@Definition,
		@DefinitionType,
		@Comment,
		@UpdateUserID,
		@DefinitionHTML,
		@UpdateDate)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @TermID,'TermDefinition')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.TermDefinition table Saved for ID: '+ convert(varchar(50), @TermID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveTermDefinition] TO [Gatekeeper_role]
GO
