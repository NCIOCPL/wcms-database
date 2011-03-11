IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_ClearDocument]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_ClearDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*************************************************************************************************************
*	NCI - National Cancer Institute
*	
*	Purpose:	
*
*	Objects Used:
*
*	Change History:
*	
*	To Do List:
*************************************************************************************************************/

CREATE PROCEDURE [dbo].[usp_ClearDocument] 
	(	
	@documentID int,
	@isDebug bit  =0	
	)
AS
BEGIN
	SET NOCOUNT ON 
	declare @updatedate datetime, @updateuserID varchar(124)
	set @updatedate = getdate()
	
	UPDATE 	Document 
	SET	Status	= 13,	-- DELETED. IsActive field will be set to 'N' and all extracted data will be cleared                                                                                                                                                                       2002-06-27 10:43:35.853                                dbo
		IsActive = 0,	-- Document NOT Active
		UpdateDate = @updatedate
	FROM 	dbo.Document 
	WHERE 	DocumentID = @DocumentID 

	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 69998, 16, 1, @DocumentID, 'Document')
		RETURN 69998
	END 	
	if @isdebug = 1  
		PRINT 'Clear Document Done'
	RETURN 0
END



GO
GRANT EXECUTE ON [dbo].[usp_ClearDocument] TO [gatekeeper_role]
GO
