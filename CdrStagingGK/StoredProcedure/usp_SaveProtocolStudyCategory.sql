IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveProtocolStudyCategory]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveProtocolStudyCategory]
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
CREATE PROCEDURE dbo.usp_SaveProtocolStudyCategory
(
	@protocolid int, 
	@updateUserid varchar(50), 
	@StudyCategoryName varchar(255), 
	@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	

	declare @updateDate datetime
	set @updatedate = getdate()	

	declare @StudyCategoryID tinyint 
	
	select @StudyCategoryID = StudyCategoryID from dbo.StudyCategory where StudyCategoryName  = @StudyCategoryName

	if @StudyCategoryID is NULL
		BEGIN
				insert into dbo.StudyCategory
					(	
						StudyCategoryName,
						UpdateUserID,
						UpdateDate)
				values(
						@StudyCategoryName,
						@UpdateUserID,
						@UpdateDate)

				IF (@@ERROR <> 0)
				BEGIN
					
					RAISERROR ( 69990, 16, 1, @ProtocolID,'StudyCategory')
					RETURN 69990
				END 
				
				set @StudyCategoryID = scope_identity()
		END

	insert into dbo.ProtocolStudyCategory
		(
			protocolid,
			updateUserid,
			StudyCategoryID,
			UpdateDate)
		values(
			@protocolid,
			@updateUserid,
			@StudyCategoryID,
			@UpdateDate)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @ProtocolID,'ProtocolStudyCategory')
		RETURN 69990
	END 


	if @isDebug =1  PRINT  '  ***       - dbo.ProtocolStudyCategory table Saved for ID: '+ convert(varchar(50), @ProtocolID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveProtocolStudyCategory] TO [Gatekeeper_role]
GO
