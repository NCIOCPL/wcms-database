IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveOrganizationName]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveOrganizationName]
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
CREATE PROCEDURE dbo.usp_SaveOrganizationName
	(
		@OrganizationID int, 
		@Name varchar(1000), 
		@Type varchar(50), 
		@UpdateUserID varchar(50), 
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	
	insert into dbo.OrganizationName
		(
		OrganizationID,
		Name,
		Type,
		UpdateUserID,
		UpdateDate)
	values(
		@OrganizationID,
		@Name,
		@Type,
		@UpdateUserID,
		@UpdateDate)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @OrganizationID,'OrganizationName')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.OrganizationName table Saved for ID: '+ convert(varchar(50), @OrganizationID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveOrganizationName] TO [Gatekeeper_role]
GO
