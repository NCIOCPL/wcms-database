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
	PRINT 'START - Push Document  to CDRLive'
	
		declare @updatedate datetime
	set @updatedate = getdate()

	if exists (select * from CDRLiveGK.dbo.document where documentid = @documentid)
	begin
		update live 
			set live.documentGUID= preview.documentGUID,
				live.documentTYpeID = preview.documentTYpeID, 
				live.version = preview.version, 
				live.isactive = preview.isactive, 
				live.updatedate =@updatedate,
				live.datelastmodified = preview.datelastModified
		 from cdrliveGK.dbo.document live inner join CDRPreviewGK.dbo.document preview 
			on live.documentid = preview.documentid
		where live.documentid = @documentid

		IF (@@ERROR <> 0)
		BEGIN
			
			RAISERROR ( 70000, 16, 1, @documentID, 'Document')
			RETURN 70000
		END 	
	end
--	insert into cdrliveGK.dbo.documentTYpe (documentTYpeid, name,comments )
--	select documentTYpeid, name,comments 
--		from cdrpreviewGK.dbo.documentTYpe 
--		where documentTypeID not in (select documenttypeid from cdrLiveGK.dbo.documentTYpe)
	
	else
	begin
		insert into cdrliveGK.dbo.document 
			(documentid, documentGUID, documentTYpeid, version, isactive, updatedate, datelastmodified)
		select documentid, documentGUID, documentTYpeid, version, isactive, @updatedate, datelastmodified 
			from cdrPreviewGK.dbo.document 
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
