IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveProtocolContactInfoHTMLMap]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveProtocolContactInfoHTMLMap]
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
CREATE PROCEDURE dbo.usp_SaveProtocolContactInfoHTMLMap
	(
	@ProtocolContactInfoHtmlID int, 
	@ProtocolContactInfoID int, 
	@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	

	insert into dbo.ProtocolContactInfoHTMLMap
	(	
			ProtocolContactInfoHtmlID,
			ProtocolContactInfoID		
	)
	VALUES (
			@ProtocolContactInfoHtmlID,
			@ProtocolContactInfoID
		
		)
	
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @ProtocolContactInfoID,'ProtocolContactInfoHTMLMap')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.ProtocolContactInfoHTMLMap table Saved for ID: '+ convert(varchar(50), @ProtocolContactInfoID)
		

	
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveProtocolContactInfoHTMLMap] TO [Gatekeeper_role]
GO
