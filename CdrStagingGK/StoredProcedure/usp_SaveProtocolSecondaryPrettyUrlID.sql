IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveProtocolSecondaryPrettyUrlID]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveProtocolSecondaryPrettyUrlID]
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
CREATE PROCEDURE dbo.usp_SaveProtocolSecondaryPrettyUrlID
	(
		@protocolid int, 
		@SecondaryPrettyUrlID varchar(50),
		@updateUserID varchar(50),
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	
	insert into dbo.ProtocolSecondaryUrl
	(	protocolid,
		IDString,
		updateUserid,
		updateDate
	)
	VALUES
	(	@protocolid,
		@SecondaryPrettyUrlID,
		@updateUserid,
		@updateDate
	)
	
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @ProtocolID,'ProtocolSecondaryPrettyUrlID')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.ProtocolSecondaryUrl table Saved for ID: '+ convert(varchar(50), @ProtocolID)
		

	if @isDebug =1  PRINT  '  ***       - dbo.ProtocolSecondaryUrl table Saved for ID: '+ convert(varchar(50), @ProtocolID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveProtocolSecondaryPrettyUrlID] TO [Gatekeeper_role]
GO
