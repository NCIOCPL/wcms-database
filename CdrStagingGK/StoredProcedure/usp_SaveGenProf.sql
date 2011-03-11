IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveGenProf]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveGenProf]
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
CREATE PROCEDURE dbo.usp_SaveGenProf
	(
		@GenProfID int, 
		@ShortName varchar(255), 
		@FirstName varchar(255), 
		@LastName varchar(255), 
		@Suffix varchar(50), 
		@Degree varchar(50), 
		@UpdateUserID varchar(50), 
		@XML ntext,
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	
	insert into dbo.GenProf
		(	
			GenProfID,
			ShortName,
			FirstName,
			LastName,
			Suffix,
			Degree,
			UpdateUserID,
			UpdateDate)
	values(
		@GenProfID,
		@ShortName,
		@FirstName,
		@LastName,
		@Suffix,
		@Degree,
		@UpdateUserID,
		@UpdateDate)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @GenProfID,'GenProf')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.GenProf table Saved for ID: '+ convert(varchar(50), @GenProfID)


	Insert into dbo.documentXML
	(documentID, XML, updateuserID, updateDate)
	values(@genprofID, @XML, @updateUserID, @updateDate)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @GenProfID,'DocumentXML')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.DocumentXML table Saved for ID: '+ convert(varchar(50), @GenProfID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveGenProf] TO [Gatekeeper_role]
GO
