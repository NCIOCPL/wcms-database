IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveTerminology]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveTerminology]
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
CREATE PROCEDURE dbo.usp_SaveTerminology
	(
		@TermID int, 
		@PreferredName nvarchar(1100), 
		@TermStatus varchar(50), 
		@Comment varchar(255), 
		@UpdateUserID varchar(50), 
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	
	insert into dbo.Terminology
		(TermID,
		PreferredName,
		TermStatus,
		Comment,
		UpdateUserID,
		UpdateDate)
	values(
		@TermID,
		@PreferredName,
		@TermStatus,
		@Comment,
		@UpdateUserID,
		@UpdateDate)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @TermID,'Terminology')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.Terminology table Saved for ID: '+ convert(varchar(50), @TermID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveTerminology] TO [Gatekeeper_role]
GO
