IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveTermOtherName]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveTermOtherName]
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
CREATE PROCEDURE dbo.usp_SaveTermOtherName
	(
		@TermID int, 
		@OtherName nvarchar(1100), 
		@OtherNameType varchar(50), 
		@ReviewStatus varchar(50), 
		@Comment varchar(2000), 
		@UpdateUserID varchar(50), 
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	
	insert into dbo.TermOtherName
		(	TermID,
		OtherName,
		OtherNameType,
		ReviewStatus,
		Comment,
		UpdateUserID,
		UpdateDate)
	values(
		@TermID,
		@OtherName,
		@OtherNameType,
		@ReviewStatus,
		@Comment,
		@UpdateUserID,
		@UpdateDate)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @TermID,'TermOtherName')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.TermOtherName table Saved for ID: '+ convert(varchar(50), @TermID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveTermOtherName] TO [Gatekeeper_role]
GO
