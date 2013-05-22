IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveGenProfCancerTypeSite]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveGenProfCancerTypeSite]
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
CREATE PROCEDURE dbo.usp_SaveGenProfCancerTypeSite
(
	@CancerTypeSite varchar(500), 
	@UpdateUserID varchar(50), 
	@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	
	if not exists(select * from dbo.GenProfCancerTypeSite where cancerTypeSite = @CancerTypeSite)
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
					
					RAISERROR ( 69990, 16, 1, 0,'GenProfCancerTypeSite')
					RETURN 69990
				END 
		END

	if @isDebug =1  PRINT  '  ***       - dbo.GenProfCancerTypeSite table Saved for '+ @CancerTypeSite 
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveGenProfCancerTypeSite] TO [Gatekeeper_role]
GO
