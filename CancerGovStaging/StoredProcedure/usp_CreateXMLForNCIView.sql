IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_CreateXMLForNCIView]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_CreateXMLForNCIView]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*
**  This procedure will create xml file for list in the format of xml_alpha template
** Need to run this in database interface and grab the print result, which will be saved as whatever.xml file.
**  Author: Jay He 04-21-02
**  Revision History:
**
**  Return Values
**  0         Success
**  70001     The guid argument was invalid
**  70004     Failed during execution 
**  70005     Failed to create
**  70006     Failed to update
**
*/
CREATE PROCEDURE [dbo].[usp_CreateXMLForNCIView]
	(
	@NCIviewID uniqueidentifier   -- this is the guid for NCIView to be approved
	)
AS
BEGIN	
	SET NOCOUNT ON
	/*
	** STEP - A
	** First Validate that the nciview guid and directoryid provided is valid
	** if not return a 70001 error
	*/		
	if(	
	  (@NCIviewID IS NULL) OR (NOT EXISTS (SELECT NCIViewID FROM nciview WHERE NCIViewID = @NCIviewID)) 
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	if (NOT EXISTS (SELECT * from viewobjects where nciviewid=@NCIviewID and type='list')) 
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	/*
	** STEP - B
	** Get nciview page physical path for insert
	** Get flag for create or update 
	** if not return a 70004 error
	*/	
	DECLARE 	@Title 		varchar(255),
		@URL		varchar(1000),
		@URLArguments	varchar(1000),
		@Result		varchar(8000),
		@ptrval 	binary(16),
		@InitialLetter	char(1),
		@PLetter	char(1)


	select @PLetter = (select min(Left(title, 1)) from nciview 
			where nciviewid in (
					select nciviewid 
					from listitem 
					where listid in (
							select listid from list  where parentlistid= (
									select objectID from viewobjects where nciviewid=@NCIviewID and type='list'
												)
						        )
					  )
			)

	select  @Result = '<?xml version="1.0" encoding="utf-8" ?> <domain><items><item><name>' + UPPER(@PLetter) + '</name><items>'  
	SELECT @ptrval = TEXTPTR([XML]) from ListXML where nciviewid=@NCIviewID
	WRITETEXT ListXML.[XML]  @ptrval @Result


	BEGIN TRAN  Tran_CreateOrUpdatePrettyURL

	BEGIN
		DECLARE ViewObject_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
			select title, url, urlArguments, UPPER(Left(title, 1)) from nciview 
			where nciviewid in (
					select nciviewid 
					from listitem 
					where listid in (
							select listid from list  where parentlistid= (
									select objectID from viewobjects where nciviewid=@NCIviewID and type='list'
												)
						        )
					  )
			order by title
		FOR READ ONLY 
		
		OPEN ViewObject_Cursor 
		
		FETCH NEXT FROM ViewObject_Cursor
		INTO 	@Title,  @URL,  @URLArguments, @InitialLetter

		WHILE @@FETCH_STATUS = 0
		BEGIN
			if @PLetter = @InitialLetter
			BEGIN
				--select @Result = @Result + '<item><name>' + @Title + '</name> <url>' + @URL + IsNull(NullIf( '?'+IsNull(@URLArguments,''),'?'),'') + '</url> </item>'   
				select @Result =  '<item><name>' + REPLACE(@Title,'&','and') + '</name> <url>' + @URL + IsNull(NullIf( '?'+IsNull(@URLArguments,''),'?'),'') + '</url> </item>'   	
			END
			ELSE
			BEGIN
				--select @Result = @Result + '</items></item><item><name>' +  UPPER(@InitialLetter)  + '</name><items><item><name>' + @Title + '</name> <url>' + @URL + IsNull(NullIf( '?'+IsNull(@URLArguments,''),'?'),'') + '</url> </item>'   
				select @Result =  '</items></item><item><name>' +  UPPER(@InitialLetter)  + '</name><items><item><name>' +  REPLACE(@Title,'&','and')  + '</name> <url>' + @URL + IsNull(NullIf( '?'+IsNull(@URLArguments,''),'?'),'') + '</url> </item>'   
			END

			SELECT @ptrval = TEXTPTR([XML]) from ListXML where nciviewid=@NCIviewID
			UPDATETEXT  ListXML.[XML]  @ptrval NULL 0 @Result

			select @PLetter = @InitialLetter

			-- GET NEXT OBJECT
		
			FETCH NEXT FROM ViewObject_Cursor
			INTO 	@Title,  @URL,  @URLArguments, @InitialLetter

		END -- End while
	
		-- CLOSE ViewObject_Cursor		
		CLOSE ViewObject_Cursor 
		DEALLOCATE ViewObject_Cursor 

	--	select @Result = @Result +   '</items></item></items></domain>'

		SELECT @ptrval = TEXTPTR([XML]) from ListXML where nciviewid=@NCIviewID
		UPDATETEXT  ListXML.[XML]  @ptrval NULL 0  '</items></item></items></domain>'

	END 

	COMMIT TRAN   Tran_CreateOrUpdatePrettyURL

	SET NOCOUNT OFF
	--PRINT '--result=      '  + @Result

END
GO
