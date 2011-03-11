IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveProtocolTypeOfCancer]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveProtocolTypeOfCancer]
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
CREATE PROCEDURE dbo.usp_SaveProtocolTypeOfCancer
	(
		@ProtocolID int, 
		@DiagnosisID int, 
		@UpdateUserID varchar(50), 
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	

	insert into dbo.ProtocolTypeOfCancer
	(	
		ProtocolID,
		DiagnosisID,
		UpdateUserID,
		updateDate
	)
	VALUES (
			@ProtocolID,
			@DiagnosisID,
			@UpdateUserID,
			@updateDate
		)
	
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @ProtocolID,'ProtocolTypeOfCancer')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.ProtocolTypeOfCancer table Saved for ID: '+ convert(varchar(50), @ProtocolID)
		

	
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveProtocolTypeOfCancer] TO [Gatekeeper_role]
GO
