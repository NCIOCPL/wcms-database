IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveProtocolSection]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveProtocolSection]
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
CREATE PROCEDURE dbo.usp_SaveProtocolSection
	(
		@ProtocolID int, 
		@SectionID int, 
		@SectionTypeID int, 
		@Audience varchar(50), 
		@HTML ntext, 
		@UpdateUserID varchar(50), 
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	

	insert into dbo.ProtocolSection
	(	
		ProtocolID,
		SectionID,
		SectionTypeID,
		Audience,
		HTML,
		UpdateUserID,
		updateDate
	)
	VALUES (
			@ProtocolID,
			@SectionID,
			@SectionTypeID,
			@Audience,
			@HTML,
			@UpdateUserID,
			@updateDate
		)
	
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @ProtocolID,'ProtocolSection')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.ProtocolSection table Saved for ID: '+ convert(varchar(50), @ProtocolID)
		

		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveProtocolSection] TO [Gatekeeper_role]
GO
