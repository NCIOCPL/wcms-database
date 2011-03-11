IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveProtocolDrug]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveProtocolDrug]
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
CREATE PROCEDURE [dbo].[usp_SaveProtocolDrug]
	(
		@ProtocolID int, 
		@DrugID int, 
		@UpdateUserID varchar(50), 
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	

	insert into dbo.ProtocolDrug
	(	
		ProtocolID,
		DrugID,
		UpdateUserID,
		updateDate
	)
	VALUES (
			@ProtocolID,
			@DrugID,
			@UpdateUserID,
			@updateDate
		)
	
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @ProtocolID,'ProtocolDrug')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.ProtocolDrug table Saved for ID: '+ convert(varchar(50), @ProtocolID)
		

	
		
END


GO
GRANT EXECUTE ON [dbo].[usp_SaveProtocolDrug] TO [Gatekeeper_role]
GO
