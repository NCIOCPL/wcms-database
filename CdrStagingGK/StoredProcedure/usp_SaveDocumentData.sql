IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveDocumentData]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveDocumentData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*	NCI - National Cancer Institute
*	
*	Purpose:	
*	Objects Used:
*
*	Change History:

*	To Do List:
*	- use transactions
*
*/
CREATE PROCEDURE dbo.usp_SaveDocumentData
	(
	@DocumentID int,
	@DocumentGUID uniqueidentifier,
	@documentTypeID tinyint,
	@isActive bit,
	@version varchar(50),
	@dateLastModified datetime = null,
	@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	declare @updateDate datetime
	set @updatedate = getdate()
	

	if exists (select * from dbo.document where documentid = @documentid)
		BEGIN
			update dbo.document
				set 
					documentTypeID = @documentTYpeID,
					version = @version,
					dateLastModified = @dateLastModified,
					updatedate = @updatedate,
					isactive = @isActive
				where documentid = @documentid
			IF (@@ERROR <> 0)
			BEGIN
					RAISERROR ( 69990, 16, 1, @DocumentID,'Document')
					RETURN 69990
			END 
		END
		ELSE
			BEGIN
				Insert into dbo.document (
							DocumentID,
							DocumentGUID,
							DocumentTypeID,
							Version,
							IsActive,
							UpdateDate,
							dateLastModified
							)
					VALUES (
							@DocumentID,
							@DocumentGUID,
							@DocumentTypeID,
							@Version,
							@isActive,
							@UpdateDate,
							@dateLastModified
							
							)
									
				IF (@@ERROR <> 0)
				BEGIN
					RAISERROR ( 69990, 16, 1, @DocumentID,'Document')
					RETURN 69990
				END 
		END
	  if @isdebug = 1  print ('usp_SaveDocumentData finish saving document: ' + convert(varchar(50), @documentid) )
			
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveDocumentData] TO [Gatekeeper_role]
GO
