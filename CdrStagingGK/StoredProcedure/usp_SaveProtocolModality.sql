IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveProtocolModality]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveProtocolModality]
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
CREATE PROCEDURE dbo.usp_SaveProtocolModality
(
	@protocolid int, 
	@updateUserid varchar(50), 
	@ModalityID int, 
	@ModalityName varchar(255),
	@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	

	declare @updateDate datetime
	set @updatedate = getdate()	

	
	
	if not exists (select * from dbo.Modality where ModalityID = @ModalityID )
		BEGIN
				insert into dbo.Modality
					(	ModalityID,
						ModalityName,
						UpdateUserID,
						UpdateDate)
				values(
						@ModalityID,
						@ModalityName,
						@UpdateUserID,
						@UpdateDate)

				IF (@@ERROR <> 0)
				BEGIN
					
					RAISERROR ( 69990, 16, 1, @ProtocolID,'Modality')
					RETURN 69990
				END 
								
		END

	insert into dbo.ProtocolModality
		(
			protocolid,
			updateUserid,
			ModalityID,
			UpdateDate)
		values(
			@protocolid,
			@updateUserid,
			@ModalityID,
			@UpdateDate)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @ProtocolID,'ProtocolModality')
		RETURN 69990
	END 


	if @isDebug =1  PRINT  '  ***       - dbo.ProtocolModality table Saved for ID: '+ convert(varchar(50), @ProtocolID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveProtocolModality] TO [Gatekeeper_role]
GO
