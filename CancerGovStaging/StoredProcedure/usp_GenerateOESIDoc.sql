IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GenerateOESIDoc]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GenerateOESIDoc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/****** 	Object:  Stored Procedure dbo.usp_InsertViewObject    -- Jhe
	Purpose: This script can be used for  pregenerating doc from docparts  Script Date: 3/5/2003 11:43:49 pM 
--	Procedure:	 
--	1. Grab all document viewobject of this nciview
--	2. Get each docpart of each document selected
--	3. Generate 	a. TOC for each document
--			b. Content of each document: <a name=heading></a> + <h2>heading</h2> + <p>content +<table>SectionEndToolBar</table>
--			c. TOC for whole nciview
--	4. Note: If a doc only has one docpart, don't display that docpart title.
--		Display doc title in the toc part
--		<previous >next will be generated in UI

--	History
--	----------
--	11/4/2003 Jay He tweaked HTML 
******/

CREATE PROCEDURE dbo.usp_GenerateOESIDoc
(
	@NCIViewID       	UniqueIdentifier,
	@UpdateUserID		VarChar(40)
)
AS
BEGIN
	SET NOCOUNT ON;

	/*
	** A. Check info and Get  viewobject's info 
	*/	
	if(	
	  (@NCIViewID  IS NULL) OR (NOT EXISTS (SELECT NCIViewID FROM NCIview WHERE NCIViewID = @NCIViewID)) 
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	Declare 	@Priority		int,
			@ObjectID		UniqueIdentifier,
		 	@DocPartID		UniqueIdentifier,
			@Title			varchar(255),	-- document title
			@ShortTitle		varchar(255),	-- document short title
			@Heading		varchar(200),	-- doc part heading
			@Toc			varchar(500),	-- document TOC
			@Data			varchar(8000),	-- document data content
			@Footer		varchar(1000),	-- footer to be added to each section
			@return_status 		int,		-- return status for executing usp_createorupdateprettyurl
			@GenTOC		varchar(8000),	-- page general TOC
			@DetailTOC		varchar(8000),	-- page detailed toc
			@RealURL		varchar(4000),	-- page real url
			@Count			int,
			@number		int,
			@TOCID		UniqueIdentifier,	-- page general TOC id
			@DetailTOCID		UniqueIdentifier,	-- page detailed toc id
			@ShowTitleOrNot	bit

	select 	@RealURL = '/Templates/' + T.URL + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'')  
	from NCITemplate T, NCIView N 
	where T.NCITemplateID=N.NCITemplateID and N.NCIViewID =@NCIviewID

	select @number=0

	select @Footer = '<br clear=all><p><table cellpadding=0 cellspacing=0 border=0 width=100%><tr><td valign=top></td><td align=right valign=bottom><a href="#top" style="color: #666699; font-size: 9pt;">return to top<img src="/images/arrow_up.gif" alt="" border=0></a></td></tr><tr><td bgcolor=#86CCCE background="/images/line_bg.gif"><img src="/images/line_left.gif"></td><td align=right bgcolor=#86CCCE background="/images/line_bg.gif"><img src="/images/line_right.gif"></td></tr></table>'

	BEGIN  TRAN   Tran_OESI

	-- since document entry exists, we update toc/data to empty string no matter there is a toc/data or not. 
	-- In this case, we won't mind whether it is a new one or exsiting one

	Update	CancerGovStaging..Document
	Set 	data ='',
		toc=''
	WHERE documentID in (select objectID from viewobjects where nciviewid=@NCIViewID and Type='Document')
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_OESI
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END

	DECLARE DOC_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
	SELECT 	V.ObjectID,  V.Priority
	FROM 		CancerGovStaging..ViewObjects V, CancerGovStaging..Document D
	WHERE  	V.NCIViewID = @NCIviewID and V.Type ='DOCUMENT' 
			and V.ObjectID = D.DocumentID
			order by V.priority
	FOR READ ONLY 
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_OESI
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
		
	OPEN DOC_Cursor 
	IF (@@ERROR <> 0)
	BEGIN
		DEALLOCATE DOC_Cursor 
		ROLLBACK TRAN Tran_OESI
		RAISERROR ( 70004, 16, 1)		
		RETURN 70004
	END 
		
	FETCH NEXT FROM DOC_Cursor
	INTO 	@ObjectID,  @Priority

	WHILE @@FETCH_STATUS = 0
	BEGIN
		select @number= @number +1

		Update	CancerGovStaging..ViewObjects
		Set 	priority   = @number
		WHERE objectID =@ObjectID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_OESI
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END

 		-- GET NEXT OBJECT
		PRINT '--get next'
		FETCH NEXT FROM DOC_Cursor 
		INTO 	@ObjectID,  @Priority

	END -- End while viewobject

	-- Create TOC view object if not exists

	if (NOT EXISTS (SELECT objectID FROM viewobjects WHERE NCIViewID = @NCIViewID and type ='TOC') )
	BEGIN
		select @TOCID = newid()

		insert into document
		(DocumentID, Title,  ShortTitle,  Description, Data, CreateDate, UpdateDate, UpdateUserID)
		values
		(@TOCID, 'TOC',  'TOC',  'TOC', '<ul>', getdate(), getdate(), @UpdateUserID)	
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_OESI
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

		INSERT INTO ViewObjects 
		(NCIViewID, ObjectID, Type, Priority, UpdateUserID) 
		VALUES 
		(@NCIViewID, @TOCID, 'TOC', 999, @UpdateUserID)
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_OESI
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END
	ELSE
	BEGIN
		SELECT @TOCID=objectID FROM viewobjects WHERE NCIViewID = @NCIViewID and type ='TOC'

		Update document
		set Data='<ul>'	
		where documentID =@TOCID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_OESI
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END

	-- Create DetailedTOC view object if not exists

	if (NOT EXISTS (SELECT objectID FROM viewobjects WHERE NCIViewID = @NCIViewID and type ='DetailTOC') )
	BEGIN
		select @DetailTOCID = newid()

		insert into document
		(DocumentID, Title,  ShortTitle,  Description, Data, CreateDate, UpdateDate, UpdateUserID)
		values
		(@DetailTOCID, 'Detailed TOC',  'Detailed TOC',  'Detailed TOC', '<ul>', getdate(), getdate(), @UpdateUserID)	
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_OESI

			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

		INSERT INTO ViewObjects 
		(NCIViewID, ObjectID, Type, Priority, UpdateUserID) 
		VALUES 
		(@NCIViewID, @DetailTOCID, 'DetailTOC', 999, @UpdateUserID)
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_OESI
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END
	ELSE
	BEGIN
		SELECT @DetailTOCID=objectID FROM viewobjects WHERE NCIViewID = @NCIViewID and type ='DetailTOC'

		Update document
		set Data='<ul>'	
		where documentID =@DetailTOCID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_OESI
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END


	DECLARE ViewObject_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
	SELECT 	V.ObjectID,  D.Title, D.ShortTitle
	FROM 		CancerGovStaging..ViewObjects V, CancerGovStaging..Document D
	WHERE  	V.NCIViewID = @NCIviewID and V.Type ='DOCUMENT' 
			and V.ObjectID = D.DocumentID
			order by V.priority
	FOR READ ONLY 
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_OESI
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
		
	OPEN ViewObject_Cursor 
	IF (@@ERROR <> 0)
	BEGIN
		DEALLOCATE ViewObject_Cursor 
		ROLLBACK TRAN Tran_OESI
		RAISERROR ( 70004, 16, 1)		
		RETURN 70004
	END 
		
	FETCH NEXT FROM ViewObject_Cursor
	INTO 	@ObjectID,  @Title, @ShortTitle

	WHILE @@FETCH_STATUS = 0
	BEGIN
			-- Generate real TOC and Detailed TOC
			-- Use real url for TOC and Detailed TOC
			select @count=count(*) from docpart where documentid=@ObjectID	

			select @GenTOC ='<li  style="list-style-image: url(/images/bullet_sm_white.gif);"><a href="'+ @RealURL+ '&docid='+ Convert(varchar(36), @ObjectID) +'" style="font-size: 12pt; color: #666699; font-weight:bold;">' + @Title +'</a>' 
			
			if (@count =1)
			BEGIN
				select @DetailTOC ='<li style="list-style-image: url(/images/bullet_sm_white.gif);"><a href="'+ @RealURL+ '&docid='+ Convert(varchar(36), @ObjectID) +'" style="font-size: 12pt; color: #666699; font-weight:bold;">' + @Title +'</a>' 
			END
			ELSE
			BEGIN
				select @DetailTOC ='<li style="list-style-image: url(/images/bullet_sm_white.gif);"><a href="'+ @RealURL+ '&docid='+ Convert(varchar(36), @ObjectID) +'" style="font-size: 12pt; color: #666699; font-weight:bold;">' + @Title +'</a><ul>' 
			END
		

	--		select @DetailTOC ='<li style="list-style-image: url(/images/bullet_sm_white.gif);"><a href="'+ @RealURL+ '&docid='+ Convert(varchar(36), @ObjectID) +'" style="font-size: 12pt; color: #666699; font-weight:bold;">' + @Title +'</a><ul>' 

			DECLARE @GenTOCval binary(16)

			SELECT @GenTOCval = TEXTPTR(data) 
			FROM  Document Where DocumentID = @TOCID

			-- update general TOC document data column with text pointer dtval, null means appending to the current toc, 0 indicates no deletion.
			UPDATETEXT Document.data @GenTOCval  null 0 @GenTOC
			IF (@@ERROR <> 0)
			BEGIN
				CLOSE ViewObject_Cursor 
				DEALLOCATE ViewObject_Cursor 
				ROLLBACK TRAN Tran_OESI
				RAISERROR ( 70004, 16, 1)		
				RETURN 70004
			END 

			DECLARE @DetailTOCval binary(16)

			SELECT @DetailTOCval = TEXTPTR(data) 
			FROM  Document Where DocumentID = @DetailTOCID

			-- update general TOC document data column with text pointer dtval, null means appending to the current toc, 0 indicates no deletion.
			UPDATETEXT Document.data @DetailTOCval  null 0 @DetailTOC
			IF (@@ERROR <> 0)
			BEGIN
				CLOSE ViewObject_Cursor 
				DEALLOCATE ViewObject_Cursor 
				ROLLBACK TRAN Tran_OESI
				RAISERROR ( 70004, 16, 1)		
				RETURN 70004
			END 

			---Loop each Docpart
			-- First update document toc=<ul>
			Update document
			set toc='<UL>'
			where documentID= @ObjectID 
			IF (@@ERROR <> 0)
			BEGIN
				CLOSE ViewObject_Cursor 
				DEALLOCATE ViewObject_Cursor 
				ROLLBACK TRAN Tran_OESI
				RAISERROR ( 70004, 16, 1)		
				RETURN 70004
			END 


			DECLARE DocPart_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
			SELECT 	DocPartID,  Heading,  Priority, ShowTitleOrNot
			FROM 		CancerGovStaging..DocPart
			WHERE  	DocumentID = @ObjectID order by priority
			FOR READ ONLY 
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_OESI
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
				
			OPEN DocPart_Cursor
			IF (@@ERROR <> 0)
			BEGIN
				DEALLOCATE DocPart_Cursor
				CLOSE ViewObject_Cursor 
				DEALLOCATE ViewObject_Cursor 
				ROLLBACK TRAN Tran_OESI
				RAISERROR ( 70004, 16, 1)		
				RETURN 70004
			END 
		
			FETCH NEXT FROM DocPart_Cursor
			INTO 	@DocPartID,  @Heading,  @Priority, @ShowTitleOrNot

			WHILE @@FETCH_STATUS = 0
			BEGIN
				PRINT 'Get each docpart heading, content, generate TOC variable content'
				-- Update data 
			/*	if (@count =1)
				BEGIN
					select @Data ='' 
					select @Toc = ''
					select @DetailTOC ='' 
				END
				ELSE
				BEGIN
					select @Data ='<P><a name="'+ Convert(varchar(3), @Priority) +'"></a><H2>' +@Heading +'</h2>'
					select @Toc = '<li><a href="#'+ Convert(varchar(3), @Priority) +'">' + @Heading +'</a>' 
					select @DetailTOC ='<li><a href="'+ @RealURL+ '&docid='+ Convert(varchar(36), @ObjectID) + '#'+ Convert(varchar(3), @Priority) +'">' + @Heading +'</a>' 
				END
			*/

				if ( @ShowTitleOrNot =0)
				BEGIN
					select @Data ='' 
					select @Toc = ''
					select @DetailTOC ='' 
				END
				ELSE
				BEGIN
					if (@count =1)
					BEGIN
						select @Data ='<a name="'+ Convert(varchar(3), @Priority) +'"></a><H2>' +@Heading +'</h2><p>'
						select @Toc = '<li><a href="#'+ Convert(varchar(3), @Priority) +'">' + @Heading +'</a></li>' 
						select @DetailTOC ='<ul><li><a href="'+ @RealURL+ '&docid='+ Convert(varchar(36), @ObjectID) + '#'+ Convert(varchar(3), @Priority) +'">' + @Heading +'</a></li></ul>' 
					END
					ELSE
					BEGIN
						select @Data ='<a name="'+ Convert(varchar(3), @Priority) +'"></a><H2>' +@Heading +'</h2><p>'
						select @Toc = '<li><a href="#'+ Convert(varchar(3), @Priority) +'">' + @Heading +'</a></li>' 
						select @DetailTOC ='<li><a href="'+ @RealURL+ '&docid='+ Convert(varchar(36), @ObjectID) + '#'+ Convert(varchar(3), @Priority) +'">' + @Heading +'</a></li>' 
					END
				END

				DECLARE @ddval binary(16)

				SELECT @ddval = TEXTPTR(data) 
				FROM  Document Where DocumentID = @ObjectID

				-- update document data column with text pointer ddval, null means appending to the current data, 0 indicates no deletion.
				UPDATETEXT Document.data @ddval  null 0  @Data
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE  DocPart_Cursor
					DEALLOCATE DocPart_Cursor
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN Tran_OESI
					RAISERROR ( 70004, 16, 1)		
					RETURN 70004
				END 

				DECLARE @Dataval binary(16)

				SELECT @Dataval = TEXTPTR(content) 
				FROM  DocPart Where DocpartID = @DocPartID

				-- update document data column with text pointer ddval, null means appending to the current data, 0 indicates no deletion.
				UPDATETEXT Document.data @ddval  null 0 DocPart.Content @Dataval
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE  DocPart_Cursor
					DEALLOCATE DocPart_Cursor
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN Tran_OESI
					RAISERROR ( 70004, 16, 1)		
					RETURN 70004
				END 

				UPDATETEXT Document.data @ddval null 0 @Footer
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE  DocPart_Cursor
					DEALLOCATE DocPart_Cursor
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN Tran_OESI
					RAISERROR ( 70004, 16, 1)		
					RETURN 70004
				END 

				-- update toc

				DECLARE @dtval binary(16)

				SELECT @dtval = TEXTPTR(toc) 
				FROM  Document Where DocumentID = @ObjectID

				-- update document toc column with text pointer dtval, null means appending to the current toc, 0 indicates no deletion.
				UPDATETEXT Document.toc @dtval  null 0 @Toc
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE  DocPart_Cursor
					DEALLOCATE DocPart_Cursor
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN Tran_OESI
					RAISERROR ( 70004, 16, 1)		
					RETURN 70004
				END 

				-- update Detail TOC 
				-- use upper level pointer
				SELECT @DetailTOCval = TEXTPTR(data) 
				FROM  Document Where DocumentID = @DetailTOCID

				UPDATETEXT Document.data @DetailTOCval  null 0 @DetailTOC
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE  DocPart_Cursor
					DEALLOCATE DocPart_Cursor
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN Tran_OESI
					RAISERROR ( 70004, 16, 1)		
					RETURN 70004
				END 

				PRINT '--get next'
				FETCH NEXT FROM DocPart_Cursor
				INTO 	@DocPartID,  @Heading, @Priority, @ShowTitleOrNot

			END -- End while docpart

			-- end document toc with '</ul>'
			DECLARE @enddtval binary(16)

			SELECT @enddtval = TEXTPTR(toc) 
			FROM  Document Where DocumentID = @ObjectID

			-- update document toc column with text pointer dtval, null means appending to the current toc, 0 indicates no deletion.
			UPDATETEXT Document.toc @enddtval  null 0 '</ul>'
	
			-- end document toc with '</ul>'
			DECLARE @endDTOCval binary(16)

			SELECT @endDTOCval = TEXTPTR(data) 
			FROM  Document Where DocumentID = @DetailTOCID

			-- update document toc column with text pointer dtval, null means appending to the current toc, 0 indicates no deletion.
			if (@count !=1)
			BEGIN
				UPDATETEXT Document.data @endDTOCval  null 0 '</ul>'
			END
			
			-- CLOSE docpart_Cursor		
			CLOSE  DocPart_Cursor
			DEALLOCATE  DocPart_Cursor

			-- GET NEXT OBJECT
			PRINT '--get next'
			FETCH NEXT FROM ViewObject_Cursor 
			INTO 	@ObjectID,  @Title, @ShortTitle

	END -- End while viewobject
	
	-- CLOSE  ViewObject_Cursor 

	CLOSE   ViewObject_Cursor 
	DEALLOCATE   ViewObject_Cursor 

	-- end  toc with '</ul>'
	DECLARE @endTOCval binary(16)

	SELECT @endTOCval = TEXTPTR(data) 
	FROM  Document Where DocumentID = @TOCID

	-- update document toc column with text pointer dtval, null means appending to the current toc, 0 indicates no deletion.
	UPDATETEXT Document.data @endTOCval  null 0 '</ul>'

	-- end  detailed toc with '</ul>'
	DECLARE @endDTOCdval binary(16)

	SELECT @endDTOCdval = TEXTPTR(data) 
	FROM  Document Where DocumentID = @DetailTOCID

	-- update document toc column with text pointer dtval, null means appending to the current toc, 0 indicates no deletion.
	UPDATETEXT Document.data @endDTOCdval  null 0 '</ul>'


	-- Create Pretty url for OESI doc 
	-- this function is introduced here in order to avoid the work on prettyurl table during creation/update/deletion

	EXEC  	@return_status= usp_CreateorUpdatePrettyURL @NCIViewID, @UpdateUserID
						
	PRINT '--	return value=' + Convert(varchar(60), @return_status)
	IF @return_status <> 0
	BEGIN
		ROLLBACK TRAN Tran_OESI
		RAISERROR ( 80014, 16, 1)
		RETURN  
	END

	COMMIT tran Tran_OESI

	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_GenerateOESIDoc] TO [webadminuser_role]
GO
