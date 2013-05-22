IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveProtocolContactInfoHTML]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveProtocolContactInfoHTML]
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
CREATE PROCEDURE dbo.usp_SaveProtocolContactInfoHTML
	(
		@ProtocolContactInfoHTMLID int  output, 
		@ProtocolID int, 
		@City char(100), 
		@State varchar(100), 
		@Country varchar(255), 
		@OrganizationName varchar(500), 
		@HTML varchar(6500), 
		@UpdateUserID varchar(50), 
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	

	insert into dbo.ProtocolContactInfoHTML
	(	
			ProtocolID,
			City,
			State,
			Country,
			OrganizationName,
			HTML,
			UpdateUserID,
			updateDate
	)
	VALUES (
			@ProtocolID,
			@City,
			@State,
			@Country,
			@OrganizationName,
			@HTML,
			@UpdateUserID,
			@updateDate
		)
	
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @ProtocolID,'ProtocolContactInfoHTML')
		RETURN 69990
	END 

	set @ProtocolContactInfoHTMLID= scope_identity()

	if @isDebug =1  PRINT  '  ***       - dbo.ProtocolContactInfoHTML table Saved for ID: '+ convert(varchar(50), @ProtocolID)
		

	
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveProtocolContactInfoHTML] TO [Gatekeeper_role]
GO
