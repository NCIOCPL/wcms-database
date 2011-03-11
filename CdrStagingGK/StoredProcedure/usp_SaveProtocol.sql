IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveProtocol]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveProtocol]
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
CREATE PROCEDURE dbo.usp_SaveProtocol
	(
		@protocolid int, 
		@IsNew bit, 
		@IsNIHClinicalCenterTrial bit, 
		@IsActiveProtocol bit, 
		@updateUserid varchar(50), 
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	

	insert into dbo.Protocol
	(	protocolid,
		IsNew,
		IsNIHClinicalCenterTrial,
		IsActiveProtocol,
		updateUserid,
		updateDate
	)
	VALUES (@protocolid,
			@IsNew,
			@IsNIHClinicalCenterTrial,
			@IsActiveProtocol,
			@updateUserid,
			@updateDate
		)
	
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @ProtocolID,'Protocol')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.Protocol table Saved for ID: '+ convert(varchar(50), @ProtocolID)
		

	if @isDebug =1  PRINT  '  ***       - dbo.ProtocolDetail table Saved for ID: '+ convert(varchar(50), @ProtocolID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveProtocol] TO [Gatekeeper_role]
GO
