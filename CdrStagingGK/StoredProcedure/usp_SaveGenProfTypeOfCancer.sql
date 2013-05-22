IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveGenProfTypeOfCancer]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveGenProfTypeOfCancer]
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
CREATE PROCEDURE dbo.usp_SaveGenProfTypeOfCancer
(
	@GenProfID int, 
	@CancerTypeSite varchar(500), 
	@FamilyCancerSyndromeID int, 
	@UpdateUserID varchar(50), 
	@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	

	declare @updateDate datetime
	set @updatedate = getdate()	

	declare @CancerTypeSiteID int 
	
	select @CancerTypeSiteID = CancerTypeSiteID from dbo.GenProfCancerTypeSite where cancerTypeSite = @CancerTypeSite

	if @CancerTypeSiteID is NULL
		BEGIN
				insert into dbo.GenProfCancerTypeSite
					(	
						CancerTypeSite,
						UpdateUserID,
						UpdateDate)
				values(
						@CancerTypeSite,
						@UpdateUserID,
						@UpdateDate)

				IF (@@ERROR <> 0)
				BEGIN
					
					RAISERROR ( 69990, 16, 1, @GenProfID,'GenProfCancerTypeSite')
					RETURN 69990
				END 
				
				set @CancerTypeSiteID = scope_identity()
		END

	insert into dbo.GenProfTypeOfCancer
		(
			GenProfID,
			CancerTypeSiteID,
			FamilyCancerSyndromeID,
			UpdateUserID,
			UpdateDate)
		values(
			@GenProfID,
			@CancerTypeSiteID,
			@FamilyCancerSyndromeID,
			@UpdateUserID,
			@UpdateDate)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @GenProfID,'GenProfTypeOfCancer')
		RETURN 69990
	END 


	if @isDebug =1  PRINT  '  ***       - dbo.GenProfTypeOfCancer table Saved for ID: '+ convert(varchar(50), @GenProfID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveGenProfTypeOfCancer] TO [Gatekeeper_role]
GO
