IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SavePoliticalSubUnit]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SavePoliticalSubUnit]
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
CREATE PROCEDURE dbo.usp_SavePoliticalSubUnit
	(
		@PoliticalSubUnitID int, 
		@FullName varchar(1000), 
		@ShortName varchar(50), 
		@CountryName varchar(1000), 
		@CountryID int, 
		@UpdateUserID varchar(50), 
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	
	insert into dbo.politicalSubUnit
		(
		PoliticalSubUnitID,
		FullName,
		ShortName,
		CountryName,
		CountryID,
		UpdateUserID,
		UpdateDate)
	values(
		@PoliticalSubUnitID,
		@FullName,
		@ShortName,
		@CountryName,
		@CountryID,
		@UpdateUserID,
		@UpdateDate)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @PoliticalSubUnitID,'politicalSubUnit')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.politicalSubUnit table Saved for ID: '+ convert(varchar(50), @PoliticalSubUnitID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SavePoliticalSubUnit] TO [Gatekeeper_role]
GO
