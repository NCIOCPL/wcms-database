IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveProtocolSpecialCategory]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveProtocolSpecialCategory]
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
CREATE PROCEDURE dbo.usp_SaveProtocolSpecialCategory
	(
		@ProtocolID int, 
		@ProtocolSpecialCategory varchar(256), 
		@UpdateUserID varchar(50), 
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	

	insert into dbo.ProtocolSpecialCategory
	(	
		ProtocolID,
		ProtocolSpecialCategory,
		UpdateUserID,
		updateDate
	)
	VALUES (
			@ProtocolID,
			@ProtocolSpecialCategory,
			@UpdateUserID,
			@updateDate
		)
	
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @ProtocolID,'ProtocolSpecialCategory')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.ProtocolSpecialCategory table Saved for ID: '+ convert(varchar(50), @ProtocolID)
		

	if @isDebug =1  PRINT  '  ***       - dbo.ProtocolSpecialCategory table Saved for ID: '+ convert(varchar(50), @ProtocolID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveProtocolSpecialCategory] TO [Gatekeeper_role]
GO
