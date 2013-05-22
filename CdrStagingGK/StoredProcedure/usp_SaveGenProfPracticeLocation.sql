IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveGenProfPracticeLocation]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveGenProfPracticeLocation]
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
CREATE PROCEDURE dbo.usp_SaveGenProfPracticeLocation
	(
	@GenProfID int, 
	@City varchar(255), 
	@State varchar(255), 
	@PostalCode varchar(15), 
	@Country varchar(255), 
	@UpdateUserID varchar(50), 
	@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	
	insert into dbo.GenProfPracticeLocation
		(	
			GenProfID,
			City,
			State,
			PostalCode,
			Country,
			UpdateUserID,
			UpdateDate)
	values(
		@GenProfID,
		@City,
		@State,
		@PostalCode,
		@Country,
		@UpdateUserID,
		@UpdateDate)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @GenProfID,'GenProfPracticeLocation')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.GenProfPracticeLocation table Saved for ID: '+ convert(varchar(50), @GenProfID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveGenProfPracticeLocation] TO [Gatekeeper_role]
GO
