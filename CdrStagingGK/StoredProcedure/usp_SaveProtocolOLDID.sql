IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveProtocolOLDID]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveProtocolOLDID]
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
CREATE PROCEDURE dbo.usp_SaveProtocolOLDID
	(
		@ProtocolID int, 
		@OldPrimaryProtocolID varchar(50),   
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	
	if not exists (select * from dbo.protocolOLDID 
					where protocolid = @protocolID and OLDPrimaryProtocolID = @OldPrimaryProtocolID)
			insert into dbo.ProtocolOLDID
			(	
				ProtocolID,
				OldPrimaryProtocolID
				
			)
			VALUES (
					@ProtocolID,
					@OldPrimaryProtocolID
				)
	
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @ProtocolID,'ProtocolOLDID')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.ProtocolOLDID table Saved for ID: '+ convert(varchar(50), @ProtocolID)
		

	
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveProtocolOLDID] TO [Gatekeeper_role]
GO
