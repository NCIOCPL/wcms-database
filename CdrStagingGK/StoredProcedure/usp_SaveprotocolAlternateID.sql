IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveprotocolAlternateID]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveprotocolAlternateID]
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
CREATE PROCEDURE dbo.usp_SaveprotocolAlternateID
(
	@protocolid int, 
	@IDstring varchar(50), 
	@updateUserid varchar(50), 
	@idtype varchar(50), 
	@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	

	declare @updateDate datetime
	set @updatedate = getdate()	

	declare @IDTypeID int 
	
	select @IDTypeID = IDTypeID from dbo.AlternateIDtype where IDtype = @IDtype

	if @IDTypeID is NULL
		BEGIN
				insert into dbo.AlternateIDtype
					(	
						IDtype,
						UpdateUserID,
						UpdateDate)
				values(
						@IDtype,
						@UpdateUserID,
						@UpdateDate)

				IF (@@ERROR <> 0)
				BEGIN
					
					RAISERROR ( 69990, 16, 1, @ProtocolID,'AlternateIDtype')
					RETURN 69990
				END 
				
				set @IDTypeID = scope_identity()
		END

	insert into dbo.protocolAlternateID
		(
			protocolid,
			IDstring,
			updateUserid,
			idtypeid,
			UpdateDate)
		values(
			@protocolid,
			@IDstring,
			@updateUserid,
			@idtypeid,
			@UpdateDate)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @ProtocolID,'protocolAlternateID')
		RETURN 69990
	END 


	if @isDebug =1  PRINT  '  ***       - dbo.protocolAlternateID table Saved for ID: '+ convert(varchar(50), @ProtocolID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveprotocolAlternateID] TO [Gatekeeper_role]
GO
