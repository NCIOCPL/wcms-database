IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_PushDocument]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_PushDocument]
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

CREATE PROCEDURE [dbo].[usp_PushDocument] 
	(
	@documentID int,
	@isDebug bit  =0	
	)
AS
BEGIN
	SET NOCOUNT ON 
	PRINT '***********************************************************************************************************************'
	PRINT 'START - Push Document  to CDRPreviewGK'
	
		declare @updatedate datetime
	set @updatedate = getdate()

	if exists (select * from CDRPreviewGK.dbo.document where documentid = @documentid)
	begin
		update preview 
			set preview.documentGUID= staging.documentGUID,
				preview.documentTYpeID = staging.documentTYpeID, 
				preview.version = staging.version, 
				preview.isactive = staging.isactive, 
				preview.updatedate =@updatedate,
				preview.datelastmodified = staging.datelastModified
		 from CDRPreviewGK.dbo.document preview inner join CDRStagingGK.dbo.document staging 
			on preview.documentid = staging.documentid
		where preview.documentid = @documentid

		IF (@@ERROR <> 0)
		BEGIN
			
			RAISERROR ( 70000, 16, 1, @documentID, 'Document')
			RETURN 70000
		END 	
	end
--	INSERT INTO CDRPreviewGK.dbo.documentTYpe (documentTYpeid, name,comments )
--	select documentTYpeid, name,comments 
--		from cdrpreviewGK.dbo.documentTYpe 
--		where documentTypeID not in (select documenttypeid from CDRPreviewGK.dbo.documentTYpe)
	
	else
	begin
		INSERT INTO CDRPreviewGK.dbo.document 
			(documentid, documentGUID, documentTYpeid, version, isactive, updatedate, datelastmodified)
		select documentid, documentGUID, documentTYpeid, version, isactive, @updatedate, datelastmodified 
			from cdrStagingGK.dbo.document 
		where documentid = @documentID
			IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70000, 16, 1, @DocumentID, 'Document')
			RETURN 70000
		END 
	end	

	RETURN 0
END


GO
GRANT EXECUTE ON [dbo].[usp_PushDocument] TO [Gatekeeper_role]
GO
