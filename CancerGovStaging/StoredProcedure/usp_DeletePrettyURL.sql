IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DeletePrettyURL]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DeletePrettyURL]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--***********************************************************************
-- Create New Object 
--************************************************************************



--***********************************************************************
-- Create New Object 
--************************************************************************
/*
**  This procedure will update pretty url for document and summary
**
**  Author: Jay He 03-08-02
**  Revision History:
** 03-20-2002 Jay He 	Added new function to load usp_checkredirectmap
** 04-05-2002 Jay He      Derived from usp_checkorUpdatePrettyURL
** 11-18-2002 Jay He	Delete summary_hp/summary_p
**  Return Values
**  0         Success
**  70001     The guid argument was invalid
**  70004     Failed during execution 
**  70005     Failed to create
**  70006     Failed to update
**
*/
CREATE PROCEDURE [dbo].[usp_DeletePrettyURL]
	(
	@PrettyURLID 		uniqueidentifier,   	-- this is the guid for PrettyURL to be Updated
	@UpdateUserID 	varchar(50)   		-- This should be the username as it appears in NCIUsers table
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
	  (@PrettyURLID IS NULL) OR (NOT EXISTS (SELECT PrettyURLID FROM   PrettyURL WHERE PrettyURLID= @PrettyURLID))
	  )	
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
	DECLARE	@NCIviewID 		uniqueidentifier,   
		@ObjectID 		uniqueidentifier,
		@ObjectType		char(10),
		@docid 		varchar(60),
		@number 		int,
		@Type 			varchar(10),
		@Template		varchar(20),
		@VOType 			varchar(10),
		@DocNumber 		int,
		@ProposedURL		varchar(2000),  
		@CurrentURL		varchar(2000)  --Exisitng current url
	
	select 	@NCIviewID=NCIViewID, @ProposedURL= proposedURL, @CurrentURL= CurrentURL from prettyurl where prettyURLID =@PrettyURLID 

		-- Need three special cases : Document, Summary, and PDF
	if (exists (select objectID from ViewObjects where nciviewID =@NCIviewID and Type like 'Summary%'))
	BEGIN
		select    @Type =  'SUMMARY'
	END
	ELSE
	BEGIN
		select    @Type =  'DOCUMENT'
	END

	PRINT '--	Type=' + @Type

	select    @DocNumber = count(*) from ViewObjects where NCIViewID =@NCIviewID and Type in ('DOCUMENT',  'AUDIO','ANIMATION', 'PHOTO')

	BEGIN TRAN  Tran_CreateOrUpdatePrettyURL

	/*
	** STEP - C
	** Loop through all objects in the ViewObjectTable and delete each documentid for prettyurl
	** if not return a 70004 error
	*/
	IF @Type = 'DOCUMENT'  AND @DocNumber >= 1
	BEGIN
		DECLARE ViewObject_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
			SELECT 	ObjectID,  '&docid=' + Convert(varchar(36), ObjectID), Priority, Type
			FROM 		CancerGovStaging..ViewObjects 
			WHERE  	NCIViewID = @NCIviewID and Type in ('DOCUMENT', 'AUDIO','ANIMATION', 'PHOTO') 
			order by priority
		FOR READ ONLY 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
		
		OPEN ViewObject_Cursor 
		IF (@@ERROR <> 0)
		BEGIN
			DEALLOCATE ViewObject_Cursor 
			ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 70004, 16, 1)		
			RETURN 70004
		END 
		
		FETCH NEXT FROM ViewObject_Cursor
		INTO 	@ObjectID,  @docid, @number, @VOType	

		WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT '-open cursor'
			Delete from CancerGovStaging..PrettyURL
			WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID 
				 AND CurrentURL =  @CurrentURL + '/Page'+Convert(varchar(4), @number) 
			IF (@@ERROR <> 0)
			BEGIN
				CLOSE ViewObject_Cursor 
				DEALLOCATE ViewObject_Cursor 
				ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70005, 16, 1)
				RETURN  70005
			END

			Delete from CancerGovStaging..PrettyURL
			WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID 
				 AND ProposedURL =  @ProposedURL  + '/Page'+Convert(varchar(4), @number)		
			IF (@@ERROR <> 0)
			BEGIN
				CLOSE ViewObject_Cursor 
				DEALLOCATE ViewObject_Cursor 
				ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70005, 16, 1)
				RETURN  70005
			END

			Delete from CancerGovStaging..PrettyURL
			WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID 
				 AND ProposedURL =  @CurrentURL  + '/Page'+Convert(varchar(4), @number)		
			IF (@@ERROR <> 0)
			BEGIN
				CLOSE ViewObject_Cursor 
				DEALLOCATE ViewObject_Cursor 
				ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70005, 16, 1)
				RETURN  70005
			END

			-- delete presentation powerpoint
			Delete from CancerGovStaging..PrettyURL
			WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID 
				 AND CurrentURL =  @CurrentURL + '/Slide'+Convert(varchar(4), @number) 
			IF (@@ERROR <> 0)
			BEGIN
				CLOSE ViewObject_Cursor 
				DEALLOCATE ViewObject_Cursor 
				ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70005, 16, 1)
				RETURN  70005
			END

			Delete from CancerGovStaging..PrettyURL
			WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID 
				 AND ProposedURL =  @ProposedURL  + '/Slide'+Convert(varchar(4), @number)		
			IF (@@ERROR <> 0)
			BEGIN
				CLOSE ViewObject_Cursor 
				DEALLOCATE ViewObject_Cursor 
				ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70005, 16, 1)
				RETURN  70005
			END

			Delete from CancerGovStaging..PrettyURL
			WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID 
				 AND ProposedURL =  @CurrentURL  + '/Slide'+Convert(varchar(4), @number)		
			IF (@@ERROR <> 0)
			BEGIN
				CLOSE ViewObject_Cursor 
				DEALLOCATE ViewObject_Cursor 
				ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70005, 16, 1)
				RETURN  70005
			END


			-- delete audio
			if (@VOType ='AUDIO')
			BEGIN
				-- Delete audio transcript pretty url
				Delete from CancerGovStaging..PrettyURL
				WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID 
					 AND CurrentURL like @CurrentURL +'/AUDIO/TRANSCRIPT%'
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
					RAISERROR ( 70005, 16, 1)
					RETURN  70005
				END

				Delete from CancerGovStaging..PrettyURL
				WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID 
					 AND ProposedURL like @ProposedURL +'/AUDIO/TRANSCRIPT%' 
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
					RAISERROR ( 70005, 16, 1)
					RETURN  70005
				END

				Delete from CancerGovStaging..PrettyURL
				WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID 
					 AND ProposedURL like @CurrentURL +'/AUDIO/TRANSCRIPT%' 
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
					RAISERROR ( 70005, 16, 1)
					RETURN  70005
				END
			END

			-- GET NEXT OBJECT
			PRINT '--get next'
			FETCH NEXT FROM ViewObject_Cursor
			INTO 	@ObjectID,  @docid, @number, @VOType	

		END -- End while
	
		-- CLOSE ViewObject_Cursor		
		CLOSE ViewObject_Cursor 
		DEALLOCATE ViewObject_Cursor 
	END  
	ELSE
	IF  	@Type = 'SUMMARY'       --- Summary 
	BEGIN
		DELETE FROM CancerGovStaging..PrettyURL
		WHERE nciviewID= @NCIviewID 
			AND CurrentURL =  @CurrentURL + '/Patient' 	Or     CurrentURL =  @CurrentURL + '/HealthProfessional'
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 70005, 16, 1)
			RETURN  70005
		END 

		DELETE FROM CancerGovStaging..PrettyURL
		WHERE nciviewID= @NCIviewID 
			AND ProposedURL =  @ProposedURL + '/Patient' 	Or     ProposedURL =  @ProposedURL + '/HealthProfessional'
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 70005, 16, 1)
			RETURN  70005
		END 
	END

	-- Delete everything from video/audio/photo

	select  @Template =UPPER(RTRIM(T.[ClassName])) from nciview N, NCITemplate T where T.NCITemplateID = N.NCITemplateID  and N.nciviewID =@NCIviewID  -- since 'Document' is the minimal type of all types we created. And 'Summary' is only type for pdq summary.

	if (@Template ='BENCHMARK')
	BEGIN
		-- delete audio
		Delete from CancerGovStaging..PrettyURL
		WHERE nciviewID= @NCIviewID 
			 AND CurrentURL = @CurrentURL +'/VIDEO'	 	
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 70005, 16, 1)
			RETURN  70005
		END

		Delete from CancerGovStaging..PrettyURL
		WHERE nciviewID= @NCIviewID 
			 AND ProposedURL = @ProposedURL  +'/VIDEO'	 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 70005, 16, 1)
			RETURN  70005
		END

		-- delete audio
		Delete from CancerGovStaging..PrettyURL
		WHERE nciviewID= @NCIviewID 
			 AND CurrentURL = @CurrentURL +'/PHOTO'	 	
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 70005, 16, 1)
			RETURN  70005
		END

		Delete from CancerGovStaging..PrettyURL
		WHERE nciviewID= @NCIviewID 
			 AND ProposedURL = @ProposedURL +'/PHOTO'	
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 70005, 16, 1)
			RETURN  70005
		END

		Delete from CancerGovStaging..PrettyURL
		WHERE nciviewID= @NCIviewID 
			 AND CurrentURL = @CurrentURL +'/AUDIO'	 	
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 70005, 16, 1)
			RETURN  70005
		END

		Delete from CancerGovStaging..PrettyURL
		WHERE nciviewID= @NCIviewID 
			 AND ProposedURL = @ProposedURL +'/AUDIO'	
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 70005, 16, 1)
			RETURN  70005
		END	
	END
	/*
	** STEP - D
	** create/update each nciview for prettyurl
	** if not return a 70004 error
	*/
	BEGIN
		Delete from CancerGovStaging..PrettyURL
		WHERE nciviewID= @NCIviewID and PrettyURLID= @PrettyURLID 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 70005, 16, 1)
			RETURN  70005
		END 
	END

	--Delete pu for multipage doc -- AllPages

	Delete from CancerGovStaging..PrettyURL
	WHERE nciviewID= @NCIviewID and CurrentURL =  @CurrentURL + '/AllPages' OR ProposedURL =  @ProposedURL  + '/AllPages'	 
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
		RAISERROR ( 70005, 16, 1)
		RETURN  70005
	END 
	
	COMMIT TRAN   Tran_CreateOrUpdatePrettyURL

	SET NOCOUNT OFF
	RETURN 0 

END

GO
GRANT EXECUTE ON [dbo].[usp_DeletePrettyURL] TO [webadminuser_role]
GO
