IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveCDRMenus]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveCDRMenus]
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
CREATE PROCEDURE dbo.usp_SaveCDRMenus
	(
		@CDRID int, 
		@MenuTypeId smallint, 
		@ParentID int, 
		@DisplayName varchar(255), 
		@SortName varchar(255), 
		@UpdateUserID varchar(50), 
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	
	insert into dbo.CDRMenus
		(	CDRID,
			MenuTypeId,
			ParentID,
			DisplayName,
			SortName,
			UpdateUserID,
			UpdateDate)
	values(
		@CDRID,
		@MenuTypeId,
		@ParentID,
		@DisplayName,
		@SortName,
		@UpdateUserID,
		@UpdateDate)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @CDRID,'CDRMenus')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.CDRMenus table Saved for ID: '+ convert(varchar(50), @CDRID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveCDRMenus] TO [Gatekeeper_role]
GO
