IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveTermSemanticType]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveTermSemanticType]
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
CREATE PROCEDURE dbo.usp_SaveTermSemanticType
	(
		@TermID int, 
		@SemanticTypeID int, 
		@SemanticTypeName varchar(100), 
		@UpdateUserID varchar(50),  
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	
	insert into dbo.TermSemanticType
		(	TermID,
		SemanticTypeID,
		SemanticTypeName,
		UpdateUserID,
		UpdateDate)
	values(
		@TermID,
		@SemanticTypeID,
		@SemanticTypeName,
		@UpdateUserID,
		@UpdateDate)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @TermID,'TermSemanticType')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.TermSemanticType table Saved for ID: '+ convert(varchar(50), @TermID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveTermSemanticType] TO [Gatekeeper_role]
GO
