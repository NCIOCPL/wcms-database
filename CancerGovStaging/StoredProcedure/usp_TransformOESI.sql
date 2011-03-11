IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_TransformOESI]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_TransformOESI]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_TransformOESI
	Purpose: This script  is used to transform OeSI to doc_img. 
	Script Date: 04/14/2004 10:43:49 pM 
******/

CREATE PROCEDURE dbo.usp_TransformOESI 
AS
BEGIN
	SET NOCOUNT ON;

	Declare @NCIViewID 		uniqueidentifier,
		@NewNCITemplateID 	uniqueidentifier,
		@OldNCITemplateID 	uniqueidentifier,
		@URL			varchar(200),
		@Title			varchar(255),
		@ShortTitle		varchar(50),
		@Description		varchar(2000),
		@ObjectID 		uniqueidentifier

	-- Select doc_img templateID
	select 		@NewNCITemplateID= ncitemplateID from  CancerGovStaging..ncitemplate where [name] like '%doc_img%'

	SELECT 	@OldNCITemplateID =  ncitemplateID from CancerGovStaging..NCITemplate where [name] like '%doc_oesi%'

	BEGIN  TRAN   Tran_TransformOESI

	PRINT '--- Using Trigger to get nciview description info out from nciview table'

	DECLARE Redirect_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
		SELECT NCIViewID, Title, ShortTitle, [Description], URL
		FROM 	CancerGovStaging..NCIView
		WHERE NCITemplateID = @OldNCITemplateID
		FOR READ ONLY 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_TransformOESI
			RAISERROR ( 80011, 16, 1)
			RETURN 
		END 
	
		--First Open pretty url cursor  for update or insert -- we get rid of unique constraint for currenturl column	
		OPEN  Redirect_Cursor 
		IF (@@ERROR <> 0)
		BEGIN
			DEALLOCATE  Redirect_Cursor 
			ROLLBACK TRAN  Tran_TransformOESI
			RAISERROR ( 80011, 16, 1)
			RETURN 
		END 
		
		FETCH NEXT FROM  Redirect_Cursor 
		INTO 	@NCIViewID, @Title, @ShortTitle, @Description, @URL
		
		--********************************************************
		-- Create HDRDOC and Change View's URL/NCITemplateID
		--********************************************************
		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- Define a new objectID for HDRDOC
			select @ObjectID = newid()

			update nciview
			set 	ncitemplateID = @NewNCITemplateID,
			    	URL = REPLACE(@URL, 'doc_multi', 'doc_img')
			where nciviewid = @NCIViewID
			IF (@@ERROR <> 0)
			BEGIN
				DEALLOCATE  Redirect_Cursor 
				ROLLBACK TRAN  Tran_TransformOESI
				RAISERROR ( 80011, 16, 1)
				RETURN 
			END 


			update  PrettyURL
			set 	RealURL = REPLACE(RealURL, 'doc_multi', 'doc_img')
			where nciviewid = @NCIViewID
			IF (@@ERROR <> 0)
			BEGIN
				DEALLOCATE  Redirect_Cursor 
				ROLLBACK TRAN  Tran_TransformOESI
				RAISERROR ( 80011, 16, 1)
				RETURN 
			END 

			insert into document
			(DocumentID, Title, ShortTitle, DataType, IsWirelessPage, Data,   ReleaseDate, ExpirationDate, UpdateDate)
			values
			(@ObjectID, @Title, @ShortTitle, 'HTML','N', @Description,  '1980-01-01 00:00:00.000', '2100-01-01 00:00:00.000', getdate())
			IF (@@ERROR <> 0)
			BEGIN
				DEALLOCATE  Redirect_Cursor 
				ROLLBACK TRAN  Tran_TransformOESI
				RAISERROR ( 80011, 16, 1)
				RETURN 
			END 

			insert into viewobjects
			(objectID, NCIViewID, Type, Priority, UpdateUserID)
			values
			(@ObjectID, @NCIViewID, 'HDRDOC', 0, 'BatchUpdateOESI')
			IF (@@ERROR <> 0)
			BEGIN
				DEALLOCATE  Redirect_Cursor 
				ROLLBACK TRAN  Tran_TransformOESI
				RAISERROR ( 80011, 16, 1)
				RETURN 
			END 

			Print 'Update View = ' + Convert(varchar(36), @NCIViewID) + ' - Successful and an HDRDOC is created with DocumentID =' +  Convert(varchar(36), @ObjectID)

			FETCH NEXT FROM Redirect_Cursor 
			INTO 	@NCIViewID, @Title, @ShortTitle, @Description, @URL
		END
					
		CLOSE  Redirect_Cursor 
		DEALLOCATE  Redirect_Cursor 

	COMMIT TRAN    Tran_TransformOESI

	SET NOCOUNT OFF
	RETURN 0 
END
GO
