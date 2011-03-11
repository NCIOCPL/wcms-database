IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveGenProfFamilyCancerSyndrome]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveGenProfFamilyCancerSyndrome]
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
CREATE PROCEDURE dbo.usp_SaveGenProfFamilyCancerSyndrome
	(
	@GenProfID int, 
	@FamilyCancerSyndrome varchar(500), 
	@UpdateUserID varchar(50), 
	@FamilyCancerSyndromeID int output,
	@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	
	insert into dbo.GenProfFamilyCancerSyndrome
		(	
			GenProfID,
			FamilyCancerSyndrome,
			UpdateUserID,
			UpdateDate)
	values(
		@GenProfID,
		@FamilyCancerSyndrome,
		@UpdateUserID,
		@UpdateDate)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @GenProfID,'GenProfFamilyCancerSyndrome')
		RETURN 69990
	END 

	set @FamilyCancerSyndromeID = scope_identity()


	if @isDebug =1  PRINT  '  ***       - dbo.GenProfFamilyCancerSyndrome table Saved for ID: '+ convert(varchar(50), @GenProfID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveGenProfFamilyCancerSyndrome] TO [Gatekeeper_role]
GO
