IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_PushNCIViewToProduction]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_PushNCIViewToProduction]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





--***********************************************************************
-- Create New Object 
--************************************************************************

/****** Object:  Stored Procedure dbo.usp_RetrieveViewObject
   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/

/*
*		EXEC sp_addmessage 80001, 16, N' CancerGov Error. Unable to update production NCI View table.','us_english', true,replace
*		EXEC sp_addmessage 80002, 16, N' CancerGov Error. Unable to update staging NCI View table.','us_english', true,replace
*		EXEC sp_addmessage 80003, 16, N' CancerGov Error. Unable to update production Document  table.','us_english', true,replace
*		EXEC sp_addmessage 80004, 16, N' CancerGov Error. Unable to insert into production Document  table.','us_english', true,replace
*		EXEC sp_addmessage 80005, 16, N' CancerGov Error. Unable to insert into production NCI View table.','us_english', true,replace
*		EXEC sp_addmessage 80006, 16, N' CancerGov Error. Please approve all related NCIViews before pushing this View to production.','us_english', true,replace
*		EXEC sp_addmessage 80007, 16, N' CancerGov Error. Unable to push records from List or  ListItem table to production.','us_english', true,replace
*		EXEC sp_addmessage 80008, 16, N' CancerGov Error. Unable to delete unused records from ViewObjects table on production.','us_english', true,replace
*		EXEC sp_addmessage 80009, 16, N' CancerGov Error. Unable to update ViewObjects table on production.','us_english', true,replace
*		EXEC sp_addmessage 80010, 16, N' CancerGov Error. Unable to insert new ViewObjects records to production.','us_english', true,replace
*		EXEC sp_addmessage 80011, 16, N' CancerGov Error. Unexpected Error, NCI View can not be pushed to production environment.','us_english', true,replace
*		EXEC sp_addmessage 80012, 16, N' CancerGov Error. NCI View {%s} not in %s status. View cannot be pushed to production environment.','us_english', true,replace
*		EXEC sp_addmessage 80013, 16, N' CancerGov Error. Unable to delete unused %s (ID=%s) from production.','us_english', true,replace
*		EXEC sp_addmessage 80014, 16, N' CancerGov Error. Unable to make changes to ViewPropery.','us_english', true,replace
*		EXEC sp_addmessage 80015, 16, N' CancerGov Error. Please approve all external new NCIViews before pushing this View to production'','us_english', true,replace
*	*	EXEC sp_addmessage 80110, 16, N' CancerGov Error. Unable to delete ViewObjectProperty (DigestRelatedListID) records from production for this nciviewobjectid .'','us_english', true,replace
*	*	EXEC sp_addmessage 80111, 16, N' CancerGov Error. Unable to insert updated ViewObjectProperty records to production'','us_english', true,replace
*	*	EXEC sp_addmessage 80112, 16, N' CancerGov Error. Unable to delete Non-existing view obejct's Property on production'','us_english', true,replace
*		
*
*		Procedure push NCIView and all related objects from CancerGovStaging to CancerGov
*
*		Change History:
*		01/07/2002 	Alex Pidlisnyy		Push Simple NCIView if it is mentioned in List table not only list 
*							item SV.Status IN ( @ReadyStatusForSimpleNCIView, @ReadyForProductionStatus ) 
* 		01/11/2002	Alex Pidlisnyy		Add code to push ViewProperty records releted to the NCIView
*		01/11/2002	Alex Pidlisnyy		Add new error message - 80014
*		02/28/2002 	Jay He			Add new viewobject Summary - Add new summary/Update existing summary/Delete unused summary
*		03/11/2002	Jay He			Add new table prettyURL - UpdateCurrentPrettyURL/Migrate to Prod./Create a record in Flag table for Chen's code to update		
*		03/19/2002	Mike Brady & Olex   	Fixed bug that would delete all listitems when removed from a list in this view 
*							( Change PLI.ListID = PLI.ListID to TLI.ListID = PLI.ListID in the step "(R) Clear Production from un used ListItems")
*		04/11/2002	Jay He			Modified PrettyURL pushing stuff to handle multiple url per page
*		04/23/2002	Jay He			Add IsRoot for prettyurl table
*		08/06/2002	Alex Pidlisnyy		Add ContentType field to Document table
*		08/08/2002	Alex Pidlisnyy		Delete ContentType field from Document table
*		09/25/2002 	Alex Pidlisnyy		Fix handling of the ViewObjectProperties deletion (check the comments in the code)
*		11/07/2002	Jay He			Comment out summary push code
*		3/21/2003	Jay He			Add view object type TSTopic
*		7/11/2003	Jay He			Add view object Link
*		7/28/2003	Jay He			Add view object ExternalObject (Animation, Audio, Photo)
*		8/13/2003	Jay He			Add function to push DigestDocList (a view object property of Digest page document)
*		10/6/2003	Jay He			Move the delete-VO-On-CancerGov before pushing VO to cancergov for header (same nciviewid, objectid but different nciviewobjectid)
*		04/16/2004	Jay He			Add NCIObjects , InfoBox for LeftNav
*		10/25/2004	Lijia Chu		Remove OLDURL,HTMLAddendum and add ReviewedDate, ChangeComments
*/

CREATE PROCEDURE [dbo].[usp_PushNCIViewToProduction] 
	(
	@NCIViewID uniqueidentifier,
	@UpdateUserID varchar(50)
	)
AS
BEGIN	
	SET NOCOUNT ON

	--PRINT 'CREATE TEMPORARY TABLES AND DECLARE VARIABLES.'
	CREATE TABLE #tmpList(
		ListID uniqueidentifier,
		Production char(1) DEFAULT 'N', -- Is this LIST on Production
		Staging char(1)  DEFAULT 'N', -- Is this LIST on Staging
		IsNCIViewExistsOnProduction char(1) DEFAULT 'N', -- Is related to that item NCIView exists on Production ('Y' - yes, 'N' - no, 'E' - exception, do not check)
		IsSimpleNCIView char(1) DEFAULT 'N' -- Simple if do not have any ViewObjects
	)		

	CREATE TABLE #tmpListItem(
		ListID uniqueidentifier,
		NCIViewID uniqueidentifier,
		Production char(1) DEFAULT 'N', -- Is this LIST on Production
		Staging char(1)  DEFAULT 'N', -- Is this LIST on Staging
		Status char(10)  DEFAULT 'SUBMIT', -- Status for related NCIView in staging database

		IsNCIViewExistsOnProduction char(1) DEFAULT 'N', -- Is related to that item NCIView exists on Production ('Y' - yes, 'N' - no, 'E' - exception, do not check)
		IsSimpleNCIView char(1) DEFAULT 'N' -- Simple if do not have any ViewObjects
	)

	DECLARE @UpdateDate datetime,
		@ProductionStatus varchar(50),
		@ReadyForProductionStatus  varchar(50),
		@ReadyStatusForSimpleNCIView  varchar(50),
		@internalError int,
	 	@NCIViewObjectID uniqueidentifier,
		@SimpleNCIViewID uniqueidentifier,
		@ObjectID uniqueidentifier,
		@ObjectType	char(10),
		@IsSimple char(1),
		@tmpStr varchar(250),
		@tmpStr1 varchar(250),
		@Prefix		varchar(1),			-- For pretty url unique 
		@PUCount	int, 
		@PrettyURLID  uniqueidentifier,	-- For pretty url
		@DirectoryID  uniqueidentifier,	-- For pretty url
		@UpdateRedirectOrNot bit,	-- For pretty url
		@IsPrimary bit,			-- For pretty ur
		@IsRoot	bit,		-- For pretty url
		@RealURL varchar(2000),	-- For pretty url
		@CurrentURL varchar(2000),	-- For pretty url
		@ProposedURL varchar(2000),   -- For pretty url
		@return_status int,		-- For pretty url usp_checkredirectmap stored proc return value
		@ReturnStatus int, 		-- used to check did the stored procedure return status 
		@DataQuolityLevel varchar(10), 	-- HIGH - Error and Stop, If any NCIViews related to that NCIView not on production
						-- MEDIUM - 
		@Type varchar(20),			-- For InfoBox
		@ObjectInstanceID uniqueidentifier	-- For InfoBox

	SELECT 	@UpdateDate = GETDATE(),
		@ReturnStatus = 0,
		@Prefix = '<',
		@ProductionStatus = 'PRODUCTION',
		@ReadyForProductionStatus = 'SUBMIT', 
		@ReadyStatusForSimpleNCIView = 'APPROVED',
		@tmpStr = '*** START Pushing NCIView {' + convert(varchar(36), @NCIViewID) + '} ***'

	PRINT '<br>***********************************************************************************************************<br>'
	PRINT @tmpStr 
	PRINT '<br>***********************************************************************************************************<br>'

	PRINT '*** Determine is the NCIView is Simple View (do not have any corespondent objects)<br>'
	IF NOT EXISTS( SELECT * FROM CancerGovStaging..ViewObjects AS VO WHERE VO.NCIViewID = @NCIViewID)
	BEGIN
		PRINT '--    Simple<br>'
		SELECT @IsSimple = 'Y'
	END
	ELSE BEGIN
		PRINT '--    NOT Simple<br>'
		SELECT @IsSimple = 'N' 
	END

	-- Check NCIView status and if it is apropriate go and push data to production 
	IF 	(
		EXISTS (SELECT * FROM CancerGovStaging..NCIView WHERE NCIViewID = @NCIViewID AND Status IN (@ReadyForProductionStatus))
		OR 
		  (
			EXISTS (SELECT * FROM CancerGovStaging..NCIView WHERE NCIViewID = @NCIViewID AND Status In (@ReadyStatusForSimpleNCIView, @ReadyForProductionStatus))
			AND 
			@IsSimple = 'Y'
		  )			
		)	
	BEGIN
		PRINT 'BEGIN TRAN Tran_PushNCIViewToProduction<br>'		
		BEGIN TRAN Tran_PushNCIViewToProduction


		--********************************************************
		-- (1) - Push just NCIView Itself  	
		--********************************************************
		-- Do we have this view on Production?
		IF (EXISTS (SELECT NCIViewID FROM CancerGov..NCIView WHERE NCIViewID = @NCIViewID))	
		BEGIN
			PRINT '*** UPDATE PRODUCTION NCIView TABLE<Br>'
			UPDATE 	Prod
			SET 	Prod.NCITemplateID = 	Staging.NCITemplateID ,
				Prod.NCISectionID = 	Staging.NCISectionID,
				Prod.GroupID = 		Staging.GroupID ,
				Prod.Title = 		Staging.Title,
				Prod.ShortTitle = 	Staging.ShortTitle,
				Prod.Description = 	Staging.Description,
				Prod.URL = 		Staging.URL,
				Prod.URLArguments = 	Staging.URLArguments,
				Prod.MetaTitle = 	Staging.MetaTitle,
				Prod.MetaDescription = 	Staging.MetaDescription,
				Prod.MetaKeyword = 	Staging.MetaKeyword,
				Prod.CreateDate = 	Staging.CreateDate,
				Prod.ReleaseDate = 	Staging.ReleaseDate,
				Prod.ExpirationDate = 	Staging.ExpirationDate,
				Prod.Version = 		dbo.GetNextVersion( Staging.Version ), -- Get Next Version so if it was 23.45 it will became 24
				Prod.Status = 		@ProductionStatus, 	-- Set Status = 'PRODUCTION'
				Prod.IsOnProduction = 	1, --Staging.IsOnProduction,
				Prod.IsMultiSourced = 	Staging.IsMultiSourced,
				Prod.IsLinkExternal = 	Staging.IsLinkExternal,
				Prod.SpiderDepth = 	Staging.SpiderDepth,
				Prod.UpdateDate = 	@UpdateDate, 		             -- Set new UpdateDate
				Prod.UpdateUserID = 	@UpdateUserID, 		-- Set new UpdateUserID	
				Prod.PostedDate      =     Staging.PostedDate,                                            
				Prod.DisplayDateMode = Staging.DisplayDateMode ,
				Prod.ReviewedDate = Staging.ReviewedDate ,
				Prod.ChangeComments = Staging.ChangeComments
			FROM 	CancerGov..NCIView Prod,
				CancerGovStaging..NCIView Staging
			WHERE 	Prod.NCIViewID = Staging.NCIViewID 
				AND Prod.NCIViewID = @NCIViewID 
			IF (@@ERROR <> 0 OR @@ROWCOUNT <> 1)
			BEGIN
				ROLLBACK TRAN 
				RAISERROR ( 80001, 16, 1)
				RETURN  
			END 
		END
		ELSE BEGIN
			PRINT '*** INSERT NEW RECORD INTO PRODUCTION NCIView TABLE<br>'
			INSERT INTO CancerGov..NCIView (NCIViewID, NCITemplateID, NCISectionID, GroupID, Title, ShortTitle, [Description], URL, URLArguments, MetaTitle,
					MetaDescription, MetaKeyword, CreateDate, ReleaseDate, ExpirationDate, Version, Status, IsOnProduction, IsMultiSourced, IsLinkExternal,
					SpiderDepth, UpdateDate, UpdateUserID, PostedDate, DisplayDateMode ,ReviewedDate,
					ChangeComments)
			SELECT 	NCIViewID,
					NCITemplateID,
					NCISectionID,
					GroupID,
					Title,
					ShortTitle,
					[Description],
					URL,
					URLArguments,
					MetaTitle,
					MetaDescription,
					MetaKeyword,
					CreateDate,
					ReleaseDate,
					ExpirationDate,
					--Version,
					dbo.GetNextVersion( Version ), -- Get Next Version so if it was 23.45 it will became 24
					@ProductionStatus AS  Status,
					1 AS IsOnProduction,
					IsMultiSourced,
					IsLinkExternal,
					SpiderDepth,
					@UpdateDate AS UpdateDate,
					@UpdateUserID AS UpdateUserID,
					PostedDate, 
					DisplayDateMode,
					ReviewedDate,
					ChangeComments
			FROM 		CancerGovStaging..NCIView 
			WHERE 	NCIViewID = @NCIViewID
			IF (@@ERROR <> 0 OR @@ROWCOUNT <> 1)
			BEGIN
				ROLLBACK TRAN 
				RAISERROR ( 80005, 16, 1)
				RETURN  
			END 
		END
		
		PRINT '*** CHANGE STATUS FOR STAGING NCIView RECORD "PRODUCTION"<br>'
		UPDATE	CancerGovStaging..NCIView 
		SET 	IsOnProduction = 1,
			Version = 	dbo.GetNextVersion( Version ), -- Get Next Version so if it was 23.45 it will became 24
			Status =	@ProductionStatus, 	-- Set Status = 'PRODUCTION'
			UpdateDate =	@UpdateDate, 		-- Set new UpdateDate
			UpdateUserID = 	@UpdateUserID 		-- Set new UpdateUserID	
		WHERE  	NCIViewID = @NCIViewID 	
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN 
			RAISERROR ( 80002, 16, 1)
			RETURN  
		END 
		
		-- Push NCIObject Second to enable LEFTNAV view 
		-- The following code might break if there are more than more nCIobjects for this nciviewid, currently there is only one.
		if (exists (select nciobjectID from CancerGovStaging..NCIObjects where NCIObjectID = @NCIViewID))
		BEGIN
			if (exists (select nciobjectID from CancerGov..NCIObjects where NCIObjectID = @NCIViewID))
			BEGIN			
				Delete from CancerGov..NCIObjects  WHERE  	 NCIObjectID = @NCIViewID 	
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN 
					RAISERROR ( 80002, 16, 1)
					RETURN  
				END 
			END

			PRINT 'Push NCIObject'
			Insert into  
			CancerGov..NCIObjects 
			(ObjectInstanceID, NCIObjectID, ParentNCIObjectID, ObjectType, Priority, UpdateDate, UpdateUserID )
			select ObjectInstanceID, NCIObjectID, ParentNCIObjectID, ObjectType, Priority, @UpdateDate, @UpdateUserID 
			from CancerGovStaging..NCIObjects 
			where NCIObjectID=@NCIViewID
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN 
				RAISERROR ( 80002, 16, 1)
				RETURN  
			END
		END

		
		PRINT '*** PUSH RELATED ViewProperty TO PRODUCTION<Br>'
		PRINT '--    DELETE UNUSED ViewProperties FROM PRODUCTION<br>'
		DELETE 
		FROM 	CancerGov..ViewProperty
		WHERE NCIViewID = @NCIViewID  and	ViewPropertyID NOT IN (
						SELECT 	Staging.ViewPropertyID
						FROM 	CancerGovStaging..ViewProperty AS Staging
						WHERE  	Staging.NCIViewID = @NCIViewID 	
						)
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN 
			RAISERROR ( 80014, 16, 1)
			RETURN  
		END 

		PRINT '--    UPDATE EXISTING ViewProperties ON PRODUCTION<br>'
		UPDATE 	Prod
		SET 	Prod.PropertyName = Staging.PropertyName,
			Prod.PropertyValue = Staging.PropertyValue,
			Prod.UpdateDate = @UpdateDate,
			Prod.UpdateUserID = @UpdateUserID
		FROM 	CancerGov..ViewProperty AS Prod,
			CancerGovStaging..ViewProperty AS Staging
		WHERE  	Staging.NCIViewID = @NCIViewID 	
			AND Staging.ViewPropertyID = Prod.ViewPropertyID 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN 
			RAISERROR ( 80014, 16, 1)
			RETURN  
		END 

		PRINT '--    INSERT NEW ViewProperties TO PRODUCTION<br>'
		INSERT INTO CancerGov..ViewProperty (ViewPropertyID, NCIViewID, PropertyName, PropertyValue, UpdateDate, UpdateUserID)
		SELECT 	Staging.ViewPropertyID, 
			Staging.NCIViewID, 
			Staging.PropertyName, 
			Staging.PropertyValue, 
			@UpdateDate, 
			@UpdateUserID
		FROM 	CancerGovStaging..ViewProperty AS Staging
		WHERE  	Staging.NCIViewID = @NCIViewID 	
			AND Staging.ViewPropertyID NOT IN (
							SELECT 	Prod.ViewPropertyID
							FROM 	CancerGov..ViewProperty AS Prod
							WHERE  	Prod.NCIViewID = @NCIViewID 	
							)
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN 
			RAISERROR ( 80014, 16, 1)
			RETURN  
		END 


--------------------
		--if it is a spanish summary, insert otherlanguageViewID to its English summary NCIView
		
		declare @EnglishViewID uniqueidentifier, @spanishViewID uniqueidentifier
	
			select @EnglishViewID = p1.propertyvalue 
				from dbo.nciview v inner join dbo.ncitemplate t on v.ncitemplateid = t.ncitemplateid
						inner join cancergov.dbo.viewproperty p on p.nciviewid = v.nciviewid
						inner join cancergov.dbo.viewproperty p1 on p1.nciviewid = v.nciviewid
						where v.nciviewid = @NCIViewID 
							and  name = 'summary'
							and  p.propertyname = 'IsSpanishContent'
							and p.propertyvalue = 'Yes'
							and p1.propertyname = 'OtherLanguageViewID'
			print 'EnglishViewID' + convert(varchar(60), @EnglishViewID)

			--if @englishViewID is NULL, it means either it is not a spanishSummary or it does not have an english summary
			if @englishViewid is not null
			BEGIN
				select @spanishViewid = propertyvalue 
					from cancergov.dbo.viewproperty 
					where nciviewid = @EnglishViewID and propertyname = 'OtherLanguageViewID'
					
				print 'spanishViewID' + convert(varchar(60), @spanishViewID)
				
				if @spanishViewID is NULL
					BEGIN
						INSERT INTO cancergov.dbo.ViewProperty
						(NCIViewID, PropertyName, PropertyValue, UpdateDate, UpdateUserID)
						VALUES
						(@EnglishViewID, 'OtherLanguageViewID', @nciviewid, getdate(),@UpdateUserID)
						IF (@@ERROR <> 0)
							BEGIN
								ROLLBACK TRAN Tran_PushNCIViewToProduction
								RAISERROR ( 80014, 16, 1)
								RETURN  
							END 
					END
					ELSE
					BEGIN
						if @spanishViewid <> @NCIViewID
						UPDATE cancergov.dbo.ViewProperty
						SET 	PropertyValue	=@NCIViewID, 
							UpdateDate	= getdate(),
							UpdateUserID	=@UpdateUserID
						WHERE 	NCIViewID= @englishViewID and PropertyName= 'OtherLanguageViewID'
						IF (@@ERROR <> 0)
						BEGIN
							ROLLBACK TRAN Tran_PushNCIViewToProduction
							RAISERROR ( 80014, 16, 1)
							RETURN  
						END 
					END
			END
		---------------------
		













		PRINT '*** PUSH RELATED PrettyURL TO PRODUCTION<br>'
		
		PRINT '--- Insert a record into redirectmap table if that pretty url exists on CancerGov but not on CancerGovStaging<Br>'
		DECLARE Redirect_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
			SELECT PrettyURLID,   ObjectID, RealURL,  CurrentURL 
			FROM 	CancerGov..PrettyURL
			WHERE NCIViewID = @NCIViewID  and	PrettyURLID NOT IN (
						SELECT 	Staging.PrettyURLID
						FROM 	CancerGovStaging..PrettyURL  AS Staging
						WHERE  	Staging.NCIViewID = @NCIViewID 
						)
		FOR READ ONLY 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN 
			RAISERROR ( 80011, 16, 1)
			RETURN 
		END 
	
		--First Open pretty url cursor  for update or insert -- we get rid of unique constraint for currenturl column	
		OPEN  Redirect_Cursor 
		IF (@@ERROR <> 0)
		BEGIN
			DEALLOCATE  Redirect_Cursor 
			ROLLBACK TRAN 
			RAISERROR ( 80011, 16, 1)
			RETURN 
		END 
		
		FETCH NEXT FROM  Redirect_Cursor 
		INTO 	@PrettyURLID, @ObjectID, @RealURL, @CurrentURL
		
		--********************************************************
		-- Push Each Related Pretty URL
		--********************************************************
		WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT '--insert into Redirect..redirectmap with deleted pretty url '+   @CurrentURL  + '<br>'
			if @ObjectID is not null
			BEGIN
				Select 	@PUCount = count(*) from CancerGovStaging..ViewObjects where objectid=@ObjectID and nciviewID=@NCIViewID
 				if @PUCount =1   -- viewobjects exist in the table
				BEGIN
					Insert into CancerGov..redirectMap (oldURL, currentURL, source)
					Values  (@CurrentURL, @RealURL, 'CancerGov')
					IF (@@ERROR <> 0)
					BEGIN
						ROLLBACK TRAN Tran_CheckRedirectMap
						RAISERROR ( 70005, 16, 1)
						RETURN 70005
					END
				END
			END
			ELSE
 			BEGIN
				PRINT '-- root entry for pretty url--<br>'
				Insert into CancerGov..redirectMap (oldURL, currentURL, source)
				Values  (@CurrentURL, @RealURL, 'CancerGov')
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN Tran_CheckRedirectMap
					RAISERROR ( 70005, 16, 1)
					RETURN 70005
				END				
			END
	
			FETCH NEXT FROM Redirect_Cursor 
			INTO 	@PrettyURLID, @ObjectID,  @RealURL, @CurrentURL
		END
					
		CLOSE  Redirect_Cursor 
		DEALLOCATE  Redirect_Cursor 

		PRINT '-- After update redirectmap table, delete all pretty urls which are not in CancerGovStaging <br>'
		DELETE 
		FROM 	CancerGov..PrettyURL
		WHERE NCIViewID = @NCIViewID  and	PrettyURLID NOT IN (
						SELECT 	Staging.PrettyURLID
						FROM 	CancerGovStaging..PrettyURL  AS Staging
						WHERE  	Staging.NCIViewID = @NCIViewID 
						)
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN 
			RAISERROR ( 80014, 16, 1)
			RETURN  
		END 

		--We need to use cursor to update/insert each prettyurl for this nciview
		DECLARE PrettyURL_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
			SELECT 	PrettyURLID,  DirectoryID, ObjectID, RealURL, ProposedURL, UpdateRedirectOrNot, IsPrimary, IsRoot 
			FROM 		CancerGovStaging..PrettyURL
			WHERE  	NCIViewID = @NCIViewID 
		FOR READ ONLY 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN 
			RAISERROR ( 80011, 16, 1)
			RETURN 
		END 
	
		--First Open pretty url cursor  for update or insert -- we get rid of unique constraint for currenturl column	
		OPEN PrettyURL_Cursor
		IF (@@ERROR <> 0)
		BEGIN
			DEALLOCATE PrettyURL_Cursor
			ROLLBACK TRAN 
			RAISERROR ( 80011, 16, 1)
			RETURN 
		END 
		
		FETCH NEXT FROM PrettyURL_Cursor
		INTO 	@PrettyURLID, @DirectoryID, @ObjectID, @RealURL, @ProposedURL, @UpdateRedirectOrNot, @IsPrimary, @IsRoot

		
		--********************************************************
		-- Push Each Related Pretty URL
		--********************************************************
		WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT '--   K--- UPDATE EXISTING CancerGovStaging..PrettyURL''s currentURL ON PRODUCTION <br>'
			PRINT '-- 	ProposedURL--' +   @ProposedURL  +'<br>'
	
			IF (@ProposedURL is not null and LEN(@ProposedURL) <>0)
			BEGIN
				PRINT '--   K---	proposedurl =' + @ProposedURL + 'length=' + Convert(Varchar(5), LEN(@ProposedURL)) +'<br>'
				UPDATE  CancerGovStaging..PrettyURL 
				SET 	CurrentURL=   @ProposedURL		--,ProposedURL =''
				WHERE  NCIViewID = @NCIViewID 	
					AND PrettyURLID = @PrettyURLID
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN 
					RAISERROR ( 80014, 16, 1)
					RETURN  
				END 
			END

			PRINT '*** PUSH PrettyURL TO PRODUCTION' +'<br>'
			IF (EXISTS (SELECT * FROM CancerGov..PrettyURL  WHERE  PrettyURLID = @PrettyURLID) and @ProposedURL is not null)
			BEGIN
				PRINT '--    Update existing prettyurl =-=-GET OLD CURRENTURL FIRST'	+'<br>'
	
				select @CurrentURL = currentURL FROM 	CancerGov..PrettyURL where PrettyURLID = @PrettyURLID
				PRINT '-- oldURL=' + @CurrentURL +' and new url = ' + @ProposedURL				
				
				PRINT '-- Find out whether there is a same currentURL as our proposedurl. If so, change it with a < in front of it-- ' +'<br>'
				IF (EXISTS (SELECT PrettyURLID FROM CancerGov..PrettyURL WHERE CurrentURL = @ProposedURL ))
				BEGIN
					PRINT '-- change exising current url ' + @ProposedURL +'to this one <' +  @ProposedURL +'<br>'
					UPDATE CancerGov..PrettyURL
						set  CurrentURL = @Prefix + CurrentURL
					WHERE  CurrentURL = @ProposedURL
					IF (@@ERROR <> 0)
					BEGIN
						ROLLBACK TRAN 
						RAISERROR ( 80014, 16, 1)
						RETURN  
					END 
				END

				PRINT '-- Find out whether the currentURL contains <. If so, get rid of it ' +'<br>'
				IF  ( exists	(select @CurrentURL where @CurrentURL like @Prefix + '%'))
				BEGIN
					PRINT 'Before change the currenurl with < back to its orginal one' + @CurrentURL +'<br>'
					select @CurrentURL= REPLACE(@CurrentURL, @Prefix, '') 
					IF (@@ERROR <> 0)
					BEGIN
						ROLLBACK TRAN 
						RAISERROR ( 80014, 16, 1)
						RETURN  
					END 
					PRINT 'After change the currenurl with < back to its orginal one' + @CurrentURL +'<br>'
				END
				
				PRINT '--    UPDATE EXISTING PrettyURL ON PRODUCTION' +'<br>'
				UPDATE 	Prod
				SET 	Prod.DirectoryID = Staging.DirectoryID,
					Prod.ObjectID	= Staging.ObjectID,
					Prod.RealURL	= Staging.RealURL,
					Prod.CurrentURL= Staging.ProposedURL,
					Prod.IsPrimary = 	   Staging.IsPrimary,
					Prod.IsNew  	= 0,
					Prod.UpdateRedirectOrNot = Staging.UpdateRedirectOrNot,
					Prod.UpdateDate = @UpdateDate,
					Prod.UpdateUserID = @UpdateUserID
				FROM 	CancerGov..PrettyURL AS Prod,
					CancerGovStaging..PrettyURL AS Staging
				WHERE  	Staging.NCIViewID = @NCIViewID 	
					AND Staging.PrettyURLID = Prod.PrettyURLID AND Prod.PrettyURLID=@PrettyURLID
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN 
					RAISERROR ( 80014, 16, 1)
					RETURN  
				END 

				-- Update RedirectMap table using stored proc usp_checkredirectmap
				IF @CurrentURL <>  @ProposedURL
				BEGIN
					PRINT '--	Update RedirectMap table if currenturl is not equal to proposedurl' +'<br>'
					PRINT '--EXEC  @return_status= usp_CheckRedirectMap ''' +  @CurrentURL+ ''' , ''' + @ProposedURL +''' , ''CancerGov'',' + Convert(varchar(1), @UpdateRedirectOrNot) +'<br>'
					EXEC  	@return_status= usp_CheckRedirectMap @CurrentURL, @ProposedURL, @RealURL,  'CancerGov', @UpdateRedirectOrNot
						
					PRINT '--	return value=' + Convert(varchar(60), @return_status)
					IF @return_status <> 0
					BEGIN
						ROLLBACK TRAN 
						RAISERROR ( 80014, 16, 1)
						RETURN  
					END
				END 
			END
			ELSE
			IF (EXISTS (SELECT * FROM CancerGov..PrettyURL  WHERE  PrettyURLID = @PrettyURLID) AND @ProposedURL is null)
			BEGIN
				PRINT '--    Update existing prettyurl, which does not change pretty url but other properties' +'<br>'
				UPDATE 	Prod
				SET 	Prod.DirectoryID = Staging.DirectoryID,
					Prod.ObjectID	= Staging.ObjectID,
					Prod.IsPrimary = 	   Staging.IsPrimary,
					Prod.IsNew  	= 0,
					Prod.UpdateRedirectOrNot = Staging.UpdateRedirectOrNot,
					Prod.UpdateDate = @UpdateDate,
					Prod.UpdateUserID = @UpdateUserID
				FROM 	CancerGov..PrettyURL AS Prod,
					CancerGovStaging..PrettyURL AS Staging
				WHERE  	Staging.NCIViewID = @NCIViewID 	
					AND Staging.PrettyURLID = Prod.PrettyURLID AND Prod.PrettyURLID=@PrettyURLID
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN 
					RAISERROR ( 80014, 16, 1)
					RETURN  
				END 
			END
			ELSE   -- Insert new prettyurl
			BEGIN
				PRINT '-- Find out whether there is a same currentURL as our proposedurl. If so, change it with a < in front of it-- ' +'<br>'
				IF (EXISTS (SELECT PrettyURLID FROM CancerGov..PrettyURL WHERE CurrentURL = @ProposedURL ))
				BEGIN
					PRINT '-- change exising current url ' + @ProposedURL +'to this one <' +  @ProposedURL +'<br>'
					UPDATE CancerGov..PrettyURL
						set  CurrentURL = @Prefix + CurrentURL
					WHERE  CurrentURL = @ProposedURL
					IF (@@ERROR <> 0)
					BEGIN
						ROLLBACK TRAN 
						RAISERROR ( 80014, 16, 1)
						RETURN  
					END 
				END

				PRINT '--    INSERT NEW PrettyURL TO PRODUCTION proposedurl=' + @ProposedURL +'<br>'
				INSERT INTO CancerGov..PrettyURL (PrettyURLID, NCIViewID, DirectoryID, ObjectID, RealURL, CurrentURL, IsNew, IsPrimary, IsRoot, UpdateRedirectOrNot, CreateDate, UpdateDate, UpdateUserID)
				VALUES
				 (@PrettyURLID, @NCIViewID, @DirectoryID, @ObjectID, @RealURL, @ProposedURL,1, @IsPrimary, @IsRoot, @UpdateRedirectOrNot, getdate(), @UpdateDate, @UpdateUserID)
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN 
					RAISERROR ( 80014, 16, 1)
					RETURN  
				END 
				
				-- Check RedirectMap tabale for proposedURL
				PRINT '--	DELETE from redirect table where proposedurl exists as oldURL' +'<br>'
				Delete from CancerGov..RedirectMap where oldURL = @ProposedURL
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN 
					RAISERROR ( 80014, 16, 1)
					RETURN  
				END 

			END

			select @CurrentURL = currentURL FROM 	CancerGov..PrettyURL where PrettyURLID = @PrettyURLID
				
			IF  ( exists	(select @CurrentURL where @CurrentURL like @Prefix + '%'))
			BEGIN
				PRINT 'Change the currenurl with < back to its orginal one' + @CurrentURL +'<br>'
				update  CancerGov..PrettyURL
				set  @CurrentURL= REPLACE(@CurrentURL, @Prefix, '') 
				WHERE  NCIViewID = @NCIViewID 	
					AND PrettyURLID = @PrettyURLID
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN 
					RAISERROR ( 80014, 16, 1)
					RETURN  
				END 
				PRINT 'After change the currenurl with < back to its orginal one' + @CurrentURL +'<br>'
			END

			FETCH NEXT FROM PrettyURL_Cursor
			INTO 	@PrettyURLID, @DirectoryID, @ObjectID, @RealURL, @ProposedURL, @UpdateRedirectOrNot, @IsPrimary, @IsRoot
		END
		
		PRINT '*** update all prettyurl for this nciview with empty proposedurl in cancergovstaging' +'<br>'
		UPDATE  CancerGovStaging..PrettyURL 
		SET 	ProposedURL =null
		WHERE  NCIViewID = @NCIViewID 	
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN 
			RAISERROR ( 80014, 16, 1)
			RETURN  
		END 

		PRINT '-- After delete all pretty urls which objectid are not in CancerGovStaging  viewobjects' +'<br>'
		DELETE 
		FROM 	CancerGov..PrettyURL
		WHERE NCIViewID = @NCIViewID  and	ObjectID  is not null and ObjectID NOT IN (
						SELECT 	Staging.ObjectID
						FROM 	CancerGovStaging..ViewObjects  AS Staging
						WHERE  	Staging.NCIViewID = @NCIViewID 
						)
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN 
			RAISERROR ( 80014, 16, 1)
			RETURN  
		END 

		PRINT '*** NCIView {'+ convert( varchar(36), @NCIViewID )+'} ITSELF PUSHED TO PRODUCTION' +'<br>'



		--********************************************************
		-- (3a) - Delete unused ViewObjects on production first
		--********************************************************
		PRINT '*** Update ViewObjects Records'		+'<br>'
		PRINT '--    Delete unused Objects (DOC, LIST, IMG) from production'+'<br>'
		DECLARE OldObjects_Cursor  CURSOR FOR 
		SELECT 	NCIViewObjectID,
			ObjectID,
			Type
		FROM 	CancerGov..ViewObjects 
		WHERE 	NCIViewID = @NCIViewID
			AND NCIViewObjectId NOT IN (
						SELECT 	NCIViewObjectId 
						FROM 	CancerGovStaging..ViewObjects 
						WHERE 	NCIViewID = @NCIViewID
						)
		
		OPEN OldObjects_Cursor 

		FETCH NEXT FROM OldObjects_Cursor  INTO @NCIViewObjectID, @ObjectID, @ObjectType	
		
		WHILE @@FETCH_STATUS = 0
		BEGIN

			-- If it is a Document and has DigestDocListID. If catch error, return error 80100
			if ((@ObjectType ='DOCUMENT') and exists (Select PropertyValue from CancerGov..ViewObjectProperty Where NCIViewObjectID = @NCIViewObjectID and PropertyName ='DigestRelatedListID'))
			BEGIN
				Print 'Push DigestDocListID related parentlist/list/listitem to production'
				EXEC  	@return_status= usp_DeleteDigestDocListForProduction @ObjectID 
						
				PRINT '--	return value=' + Convert(varchar(60), @return_status)
				IF @return_status <> 0
				BEGIN
					CLOSE OldObjects_Cursor 
					DEALLOCATE OldObjects_Cursor  
					ROLLBACK TRAN 
					SELECT 	@tmpStr = CONVERT(varchar(36), @ObjectID)
					RAISERROR ( @return_status, 16, 1, @ObjectType, @tmpStr )
					RETURN  
				END 	
			END

			-- Delete Non-existing view obejct's Property on production 
			DELETE	CancerGov.dbo.ViewObjectProperty
			FROM 		CancerGov.dbo.ViewObjectProperty
			WHERE 	NCIViewObjectID = @NCIViewObjectID
			IF @@ERROR  <> 0
			BEGIN
				CLOSE OldObjects_Cursor 
				DEALLOCATE OldObjects_Cursor  
				ROLLBACK TRAN 
				SELECT 	@tmpStr = CONVERT(varchar(36), @ObjectID)
				RAISERROR ( 80112, 16, 1, @ObjectType, @tmpStr )
				RETURN  
			END 	

			
			SELECT @NCIViewObjectID AS '1', @ObjectID AS '2', @ObjectType as '3'				

			IF	@ObjectType = 'LIST' 
				OR @ObjectType = 'HDRLIST' 
				OR @ObjectType = 'NAVLIST' 
				OR @ObjectType = 'TIPLIST' 
				OR @ObjectType = 'HELPLIST' 
				OR @ObjectType = 'PDQLIST'

			BEGIN
				IF EXISTS (SELECT * FROM CancerGov..ViewObjects WHERE ObjectID = @ObjectID AND NOT NCIViewID = @NCIViewID)
				BEGIN
					PRINT ' ---    Unable to delete ' + @ObjectType + ' (' + convert(varchar(36),@ObjectID) + '), because it linked to other NCIView' +'<br>'
				END 
				ELSE BEGIN
					PRINT ' ---    Delete unused List-Family Objects from production'+'<br>'
					PRINT '   a)    Delete List items and Child List Items'+'<br>'
					DELETE 	FROM CancerGov..ListItem
					WHERE 	ListID IN 	( 	
								--Child Lists which are not used anywhere else
								SELECT 	ListID 
								FROM 	CancerGov..List AS L 
									INNER JOIN CancerGov..ViewObjects AS VO 
									ON VO.ObjectID = L.ListID
								WHERE 	L.ParentListID = @ObjectID 
									AND NOT VO.NCIViewID = @NCIViewID
								)
						OR ListID = @ObjectID
						
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE OldObjects_Cursor 
						DEALLOCATE OldObjects_Cursor  
						ROLLBACK TRAN 
						SELECT 	@tmpStr = CONVERT(varchar(36), @ObjectID)
						RAISERROR ( 80013, 16, 1, @ObjectType, @tmpStr )
						RETURN  
					END 

					PRINT '   b)    Delete List'+'<br>'
					DELETE 	FROM CancerGov..List
					WHERE 	ListID = @ObjectID
	
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE OldObjects_Cursor 
						DEALLOCATE OldObjects_Cursor 
						ROLLBACK TRAN 
						SELECT 	@tmpStr = CONVERT(varchar(36), @ObjectID)
						RAISERROR ( 80013, 16, 1, @ObjectType, @tmpStr )
						RETURN  
					END 

					PRINT '   c)    Delete Child Lists which are not used anywhere else'+'<br>'
					DELETE FROM CancerGov..List 
					WHERE ListID IN (
							SELECT 	ListID 
							FROM 	CancerGov..List AS L 
								INNER JOIN CancerGov..ViewObjects AS VO 
								ON VO.ObjectID = L.ListID
							WHERE 	L.ParentListID = @ObjectID 
								AND NOT VO.NCIViewID = @NCIViewID
							)
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE OldObjects_Cursor 

						DEALLOCATE OldObjects_Cursor 
						ROLLBACK TRAN 
						SELECT 	@tmpStr = CONVERT(varchar(36), @ObjectID)
						RAISERROR ( 80013, 16, 1, @ObjectType, @tmpStr )
						RETURN  
					END 

				END
			END
			ELSE 
			IF 	@ObjectType = 'NAVDOC'
				OR @ObjectType = 'DOCUMENT'
				OR @ObjectType = 'HDRDOC'
				OR @ObjectType = 'SEARCH'
				OR @ObjectType = 'VIRSEARCH'	-- 5/3/2004
				OR @ObjectType = 'INCLUDE' 
				OR @ObjectType = 'TXTINCLUDE' 
				OR @ObjectType = 'TOC'		-- 3/21/2003 Jay He for OESI
				OR @ObjectType = 'DETAILTOC'	-- 3/21/2003 Jay He for OESI
			BEGIN
				IF EXISTS (SELECT * FROM CancerGov..ViewObjects WHERE ObjectID = @ObjectID AND NOT NCIViewID = @NCIViewID)
				BEGIN
					PRINT ' ---    Unable to delete ' + @ObjectType + ' (' + convert(varchar(36),@ObjectID) + '), because it linked to other NCIView' +'<br>'
				END 
				ELSE BEGIN
					PRINT ' ---    Delete unused ' + @ObjectType + ' (' + convert(varchar(36),@ObjectID) + ') Objects from production'+'<br>'
					DELETE FROM CancerGov..Document
					WHERE 	DocumentID = @ObjectID
	
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE OldObjects_Cursor 
						DEALLOCATE OldObjects_Cursor 
						ROLLBACK TRAN 
						SELECT 	@tmpStr = CONVERT(varchar(36), @ObjectID)
						RAISERROR ( 80013, 16, 1, @ObjectType, @tmpStr )
						RETURN  
					END 
				END
			END	
			ELSE 
			IF 	@ObjectType = 'IMAGE'
			BEGIN
				IF EXISTS (SELECT * FROM CancerGov..ViewObjects WHERE ObjectID = @ObjectID AND NOT NCIViewID = @NCIViewID)
				BEGIN
					PRINT ' ---    Unable to delete ' + @ObjectType + ' (' + convert(varchar(36),@ObjectID) + '), because it linked to other NCIView' +'<br>'
				END 
				ELSE BEGIN
					PRINT ' ---    Delete unused Image Objects from production'+'<br>'
					DELETE FROM CancerGov..Image
					WHERE ImageID = @ObjectID
	
					IF (@@ERROR <> 0)

					BEGIN
						CLOSE OldObjects_Cursor 
						DEALLOCATE OldObjects_Cursor 
						ROLLBACK TRAN 
						SELECT 	@tmpStr = CONVERT(varchar(36), @ObjectID)
						RAISERROR ( 80013, 16, 1, @ObjectType, @tmpStr )
						RETURN  
					END 
				END 
			END
			ELSE 
			IF 	@ObjectType = 'TSTOPIC'
			BEGIN
				IF EXISTS (SELECT * FROM CancerGov..ViewObjects WHERE ObjectID = @ObjectID AND NOT NCIViewID = @NCIViewID)
				BEGIN
					PRINT ' ---    Unable to delete ' + @ObjectType + ' (' + convert(varchar(36),@ObjectID) + '), because it linked to other NCIView' +'<br>'
				END 
				ELSE BEGIN
					PRINT ' ---    Delete unused Image Objects from production'+'<br>'
					DELETE FROM CancerGov..TSTopics
					WHERE TopicID = @ObjectID
	
					IF (@@ERROR <> 0)

					BEGIN
						CLOSE OldObjects_Cursor 
						DEALLOCATE OldObjects_Cursor 
						ROLLBACK TRAN 
						SELECT 	@tmpStr = CONVERT(varchar(36), @ObjectID)
						RAISERROR ( 80013, 16, 1, @ObjectType, @tmpStr )
						RETURN  
					END 
				END 
			END
			ELSE 
			IF 	 @ObjectType = 'EFormSCode'
			     or  @ObjectType = 'EFormWCode'
			     or  @ObjectType = 'EFormSHelp'
			     or  @ObjectType = 'EFormWHelp' 
			BEGIN
				IF EXISTS (SELECT * FROM CancerGov..ViewObjects WHERE ObjectID = @ObjectID AND NOT NCIViewID = @NCIViewID)
				BEGIN
					PRINT ' ---    Unable to delete ' + @ObjectType + ' (' + convert(varchar(36),@ObjectID) + '), because it linked to other NCIView' +'<br>'
				END 
				ELSE BEGIN
					PRINT ' ---    Don''t delete unused Segment Objects from production since it is in another version'+'<br>'
				END 
			END  -- End of 'EformSegment' Handler
			ELSE 
			IF 	@ObjectType = 'LINK'
			BEGIN
				PRINT ' ---    Unable to delete ' + @ObjectType + ' (' + convert(varchar(36),@ObjectID) + '), because it is other NCIView' +'<br>'
			END
			ELSE
			IF 	@ObjectType = 'ANIMATION'
				     or  @ObjectType = 'AUDIO'
				     or  @ObjectType ='PHOTO'
			BEGIN
				IF EXISTS (SELECT * FROM CancerGov..ViewObjects WHERE ObjectID = @ObjectID AND NOT NCIViewID = @NCIViewID)
				BEGIN
					PRINT ' ---    Unable to delete ' + @ObjectType + ' (' + convert(varchar(36),@ObjectID) + '), because it linked to other NCIView' +'<br>'
				END 
				ELSE BEGIN
					PRINT ' ---    Delete unused Image Objects from production'+'<br>'
					DELETE FROM CancerGov..[ExternalObject] WHERE ExternalObjectID = @ObjectID
	

					IF (@@ERROR <> 0)

					BEGIN
						CLOSE OldObjects_Cursor 
						DEALLOCATE OldObjects_Cursor 
						ROLLBACK TRAN 
						SELECT 	@tmpStr = CONVERT(varchar(36), @ObjectID)
						RAISERROR ( 80013, 16, 1, @ObjectType, @tmpStr )
						RETURN  
					END 
				END 
			END  -- End of 'ExternalObject' Handler
			ELSE
			IF 	@ObjectType = 'NLSECTION'
			BEGIN
				IF EXISTS (SELECT * FROM CancerGov..ViewObjects WHERE ObjectID = @ObjectID AND NOT NCIViewID = @NCIViewID)
				BEGIN
					PRINT ' ---    Unable to delete ' + @ObjectType + ' (' + convert(varchar(36),@ObjectID) + '), because it linked to other NCIView' +'<br>'
				END 
				ELSE BEGIN
					PRINT ' ---    Delete unused  NLSection Objects from production'+'<br>'
					DELETE FROM CancerGov..[NLSection] WHERE NLSectionID= @ObjectID
	

					IF (@@ERROR <> 0)

					BEGIN
						CLOSE OldObjects_Cursor 
						DEALLOCATE OldObjects_Cursor 
						ROLLBACK TRAN 
						SELECT 	@tmpStr = CONVERT(varchar(36), @ObjectID)
						RAISERROR ( 80013, 16, 1, @ObjectType, @tmpStr )
						RETURN  
					END 
				END 
			END
			ELSE
			IF 	@ObjectType = 'NLLIST'
			BEGIN
				IF EXISTS (SELECT * FROM CancerGov..ViewObjects WHERE ObjectID = @ObjectID AND NOT NCIViewID = @NCIViewID)
				BEGIN
					PRINT ' ---    Unable to delete ' + @ObjectType + ' (' + convert(varchar(36),@ObjectID) + '), because it linked to other NCIView' +'<br>'
				END 
				ELSE BEGIN
					PRINT ' ---    Delete unused List-Family Objects from production'+'<br>'
					PRINT '   a)    Delete List items and Child List Items'+'<br>'
					DELETE 	FROM CancerGov..NLListItem
					WHERE 	ListID IN 	( 	
								--Child Lists which are not used anywhere else
								SELECT 	ListID 
								FROM 	CancerGov..List AS L 
									INNER JOIN CancerGov..ViewObjects AS VO 
									ON VO.ObjectID = L.ListID
								WHERE 	L.ParentListID = @ObjectID 
									AND NOT VO.NCIViewID = @NCIViewID
								)
						OR ListID = @ObjectID
						
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE OldObjects_Cursor 
						DEALLOCATE OldObjects_Cursor  
						ROLLBACK TRAN 
						SELECT 	@tmpStr = CONVERT(varchar(36), @ObjectID)
						RAISERROR ( 80013, 16, 1, @ObjectType, @tmpStr )
						RETURN  
					END 

					PRINT '   b)    Delete List'+'<br>'
					DELETE 	FROM CancerGov..List
					WHERE 	ListID = @ObjectID
	
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE OldObjects_Cursor 
						DEALLOCATE OldObjects_Cursor 
						ROLLBACK TRAN 
						SELECT 	@tmpStr = CONVERT(varchar(36), @ObjectID)
						RAISERROR ( 80013, 16, 1, @ObjectType, @tmpStr )
						RETURN  
					END 

					PRINT '   c)    Delete Child Lists which are not used anywhere else'+'<br>'
					DELETE FROM CancerGov..List 
					WHERE ListID IN (
							SELECT 	ListID 
							FROM 	CancerGov..List AS L 
								INNER JOIN CancerGov..ViewObjects AS VO 
								ON VO.ObjectID = L.ListID
							WHERE 	L.ParentListID = @ObjectID 
								AND NOT VO.NCIViewID = @NCIViewID
							)
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE OldObjects_Cursor 

						DEALLOCATE OldObjects_Cursor 
						ROLLBACK TRAN 
						SELECT 	@tmpStr = CONVERT(varchar(36), @ObjectID)
						RAISERROR ( 80013, 16, 1, @ObjectType, @tmpStr )
						RETURN  
					END 

				END
			END
			ELSE IF (@ObjectType = 'INFOBOX'  )
			BEGIN
				/*
				** Delete infobox -- NCIObjects/NCIobjectProperty/List/Image/Doc
				*/
				if (exists ( select ObjectType from CancerGov..NCIObjects where ParentNCIObjectID = @ObjectID))
				BEGIN
					--select @Type = ObjectType, @ObjectInstanceID = ObjectInstanceID from CancerGov..NCIObjects where ParentNCIObjectID = @ObjectID
					--Loop through each child nciobject for leftnav

					DECLARE NCIObject_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
					SELECT  ObjectType , ObjectInstanceID
					from 	CancerGov..NCIObjects 
					where ParentNCIObjectID = @ObjectID
					FOR READ ONLY 
					IF (@@ERROR <> 0)
					BEGIN
						DEALLOCATE OldObjects_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END 
			
					OPEN NCIObject_Cursor 
					IF (@@ERROR <> 0)
					BEGIN
						DEALLOCATE NCIObject_Cursor 
						Close  OldObjects_Cursor 
						DEALLOCATE OldObjects_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 70004, 16, 1)		
						RETURN 70004
					END 
			
					FETCH NEXT FROM NCIObject_Cursor
					INTO 	 @Type, @ObjectInstanceID
	
					WHILE @@FETCH_STATUS = 0
					BEGIN		
	
						Print 'parentNCIID=' + Convert(varchar(36), @ObjectInstanceID)

						PRINT '--EXEC  @return_status= usp_deleteNCIObject ''' + Convert(varchar(36), @ObjectID) +'<br>'
						EXEC  	@returnStatus= usp_DeleteNCIObjectforProduction @ObjectInstanceID, @Type, 'websiteuser'
				
						IF (@returnStatus <> 0)
						BEGIN
							Close  NCIObject_Cursor
							DEALLOCATE NCIObject_Cursor
							Close  OldObjects_Cursor 
							DEALLOCATE OldObjects_Cursor 
							ROLLBACK TRAN 
							RAISERROR ( 70004, 16, 1)
							RETURN 70004
						END 	
					
						FETCH NEXT FROM NCIObject_Cursor
						INTO 	@Type, @ObjectInstanceID
					END
		
					CLOSE  NCIObject_Cursor 
					DEALLOCATE NCIObject_Cursor 		
			
				END 	
			END 

			DELETE 	CancerGov..ViewObjects 
			FROM 	CancerGov..ViewObjects 
			WHERE 	NCIViewObjectID = @NCIViewObjectID
			IF (@@ERROR <> 0)
			BEGIN
				CLOSE OldObjects_Cursor 

				DEALLOCATE OldObjects_Cursor 
				ROLLBACK TRAN 
				SELECT 	@tmpStr = CONVERT(varchar(36), @ObjectID)
				RAISERROR ( 80013, 16, 1, @ObjectType, @tmpStr )
				RETURN  
			END 

			FETCH NEXT FROM OldObjects_Cursor  INTO @NCIViewObjectID, @ObjectID, @ObjectType	
		END
		
		CLOSE OldObjects_Cursor 
		DEALLOCATE OldObjects_Cursor 



		--********************************************************
		PRINT '*** Loop through all objects in the ViewObjectTable and Push them to production to' +'<br>'
		--********************************************************
		DECLARE ViewObject_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
			SELECT 	 NCIViewObjectID, ObjectID, Type
			FROM 		CancerGovStaging..ViewObjects
			WHERE  	NCIViewID = @NCIViewID 	
		FOR READ ONLY 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN 
			RAISERROR ( 80011, 16, 1)
			RETURN 
		END 
		
		OPEN ViewObject_Cursor 
		IF (@@ERROR <> 0)
		BEGIN
			DEALLOCATE ViewObject_Cursor 
			ROLLBACK TRAN 
			RAISERROR ( 80011, 16, 1)

			RETURN 
		END 
		
		FETCH NEXT FROM ViewObject_Cursor
		INTO 	@NCIViewObjectID, @ObjectID, @ObjectType	
		
		--********************************************************
		-- Push Each Related Object
		--********************************************************
		WHILE @@FETCH_STATUS = 0
		BEGIN


			SELECT @tmpStr = '       +++ '+ @ObjectType +' +++'
			PRINT @tmpStr 

			-- 'DOCUMENT' or 'HDRDOC'	or 'NAVDOC' or 'SEARCH'			
			IF 	@ObjectType = 'DOCUMENT' 
				OR @ObjectType = 'HDRDOC' 
				OR  @ObjectType = 'NAVDOC' 		-- 12/27/2001 New Object type Added
				OR  @ObjectType = 'SEARCH'		-- 09/13/2002 New Object type added by Jay
				OR  @ObjectType = 'VIRSEARCH'	-- 05/3/2004 New Object type added by Jay
				OR @ObjectType = 'INCLUDE' 
				OR @ObjectType = 'TXTINCLUDE' 	-- 1/10/2003 Added by Jay He
				OR @ObjectType = 'TOC'		-- 3/21/2003 Jay He for OESI
				OR @ObjectType = 'DETAILTOC'	-- 3/21/2003 Jay He for OESI
			BEGIN
				PRINT '*** PUSH DOCUMENT TO PRODUCTION' +'<br>'
				IF (EXISTS (SELECT * FROM CancerGov..Document WHERE  DocumentID = @ObjectID))
				BEGIN
					PRINT '--    Upadate Existing Document' +'<br>'
					UPDATE Prod
					SET	Prod.Title 		= Staging.Title,
						Prod.ShortTitle 		= Staging.ShortTitle,
						Prod.Description 	= Staging.Description,
						Prod.GroupID 		= Staging.GroupID,
						Prod.DataType 		= Staging.DataType,
						--Prod.ContentType 	= Staging.ContentType,
						Prod.DataSize  		= Staging.DataSize ,
						Prod.IsWirelessPage 	= Staging.IsWirelessPage,
						Prod.TOC 		= Staging.TOC,
						Prod.Data 		= Staging.Data,
						Prod.RunTimeOwnerID 	= Staging.RunTimeOwnerID,
						Prod.PostedDate		= Staging.PostedDate,
						Prod.DisplayDateMode	= Staging.DisplayDateMode,
						Prod.CreateDate 	= Staging.CreateDate,
						Prod.ReleaseDate 	= Staging.ReleaseDate,
						Prod.ExpirationDate 	= Staging.ExpirationDate,
						Prod.UpdateDate 	= @UpdateDate,
						Prod.UpdateUserID  	= @UpdateUserID 
					FROM 	CancerGov..Document AS Prod, CancerGovStaging..Document AS Staging
					WHERE Staging.DocumentID = Prod.DocumentID
						AND Prod.DocumentID = @ObjectID
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 

						RAISERROR ( 80003, 16, 1)
						RETURN  
					END 
				END ELSE
				BEGIN
					PRINT '--    Insert New Document' +'<br>'
					INSERT INTO 	CancerGov..Document (DocumentID, Title, ShortTitle, [Description], GroupID, DataType, /*ContentType,*/ DataSize, IsWirelessPage, 
								TOC, Data, RunTimeOwnerID, CreateDate, ReleaseDate,PostedDate, DisplayDateMode,ExpirationDate, UpdateDate, UpdateUserID)
					SELECT 	DocumentID,
							Title,
							ShortTitle,
							[Description],
							GroupID,
							DataType,
							--ContentType,
							DataSize,
							IsWirelessPage,
							TOC,
							Data,
							RunTimeOwnerID,
							CreateDate,
							ReleaseDate,
							PostedDate,
							DisplayDateMode,
							ExpirationDate,
							@UpdateDate AS UpdateDate,
							@UpdateUserID  AS UpdateUserID
					FROM 	CancerGovStaging..Document 
					WHERE DocumentID = @ObjectID					 	
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80004, 16, 1)
						RETURN  
					END 
				END

			END -- End of 'DOCUMENT' or 'HDRDOC' Handler
			ELSE 
			-- Any kind of lists 

			IF 	@ObjectType = 'LIST' 
				OR @ObjectType = 'HDRLIST' 
				OR @ObjectType = 'NAVLIST' 
				OR @ObjectType = 'TIPLIST' 
				OR @ObjectType = 'HELPLIST' 
				OR @ObjectType = 'PDQLIST'
				OR @ObjectType = 'NLLIST'
			BEGIN 
				PRINT '**** PUSH LIST TO PRODUCTION' +'<br>'
				PRINT '--    (A) get all List IDs which suppose to be pushed ' +'<br>'
				INSERT INTO #tmpList (ListID, Production, Staging)
				SELECT 	ListID, 
					'N' AS Production,
					'Y' AS Staging	
				FROM 	CancerGovStaging..List  
				WHERE  	ListID = @ObjectID 	
					OR ListID IN ( SELECT DISTINCT ListID FROM CancerGovStaging..List WHERE ParentListID = @ObjectID ) 
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN 
					RAISERROR ( 80006, 16, 1)
					RETURN  
				END 

				PRINT '--    (B) get List IDs which on Production but not on Staging (those need to be deleted late)' +'<br>'
				INSERT INTO #tmpList (ListID, Production, Staging)
				SELECT 	ListID, 
					'Y' AS Production,
					'N' AS Staging	
				FROM 	CancerGov..List  
				WHERE  	(
					  ListID = @ObjectID 	
					  OR 
					  ListID IN ( SELECT DISTINCT ListID FROM CancerGov..List WHERE ParentListID = @ObjectID ) 
					)
					AND ListID NOT IN (SELECT ListID FROM #tmpList)
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN 
					RAISERROR ( 80006, 16, 1)
					RETURN  
				END 

				PRINT '--    (C) Get all Staging List Items. 2 cases: NLList and others' +'<br>'
				if (@ObjectType = 'NLLIST')
				BEGIN
					INSERT INTO #tmpListItem (ListID, NCIViewID, Production, Staging, Status)
					SELECT 	L.ListID, 
						L.NCIViewID , 
						'N' AS Production,
						'Y' AS Staging,
						V.Status 	
					FROM 	CancerGovStaging..NLListItem L
						INNER JOIN CancerGovStaging..NCIView V
							ON L.NCIViewID = V.NCIViewID 
							AND L.ListID IN (SELECT ListID FROM #tmpList)
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80006, 16, 1)
						RETURN  
					END 
				END
				ELSE
				BEGIN
					INSERT INTO #tmpListItem (ListID, NCIViewID, Production, Staging, Status)
					SELECT 	L.ListID, 
						L.NCIViewID , 
						'N' AS Production,
						'Y' AS Staging,
						V.Status 	
					FROM 	CancerGovStaging..ListItem L
						INNER JOIN CancerGovStaging..NCIView V
							ON L.NCIViewID = V.NCIViewID 
							AND L.ListID IN (SELECT ListID FROM #tmpList)
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80006, 16, 1)
						RETURN  
					END 
				END

				PRINT '--    (D) Get all Production List Items. 2 cases: NLList and others' +'<br>'
				if (@ObjectType = 'NLLIST')
				BEGIN
					INSERT INTO #tmpListItem (ListID, NCIViewID, Production, Staging, Status)
					SELECT 	L.ListID, 
						L.NCIViewID , 
						'Y' AS Production,
						'N' AS Staging,
						'EXCEPTION' AS Status 	
					FROM 	CancerGov..NLListItem L
						INNER JOIN CancerGov..NCIView V
							ON L.NCIViewID = V.NCIViewID 
							AND L.ListID IN (SELECT ListID FROM #tmpList)
					WHERE 	convert(varchar(36),L.ListID) + convert(varchar(36),L.NCIViewID) NOT IN  (SELECT convert(varchar(36),ListID) + convert(varchar(36),NCIViewID) FROM #tmpListItem) 
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80006, 16, 1)
						RETURN  
					END
				END
				ELSE
				BEGIN
					INSERT INTO #tmpListItem (ListID, NCIViewID, Production, Staging, Status)
					SELECT 	L.ListID, 
						L.NCIViewID , 
						'Y' AS Production,
						'N' AS Staging,
						'EXCEPTION' AS Status 	
					FROM 	CancerGov..ListItem L
						INNER JOIN CancerGov..NCIView V
							ON L.NCIViewID = V.NCIViewID 
							AND L.ListID IN (SELECT ListID FROM #tmpList)
					WHERE 	convert(varchar(36),L.ListID) + convert(varchar(36),L.NCIViewID) NOT IN  (SELECT convert(varchar(36),ListID) + convert(varchar(36),NCIViewID) FROM #tmpListItem) 
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80006, 16, 1)
						RETURN  
					END
				END			 
			
				PRINT '--    (E) Find out is the related to List NCIViews exists on production' +'<br>'
				UPDATE 	TL 
				SET 	IsNCIViewExistsOnProduction = 'Y'
				FROM 	CancerGov..NCIView AS ProdV, 
					#tmpList AS TL
					INNER JOIN CancerGovStaging..List AS L
					ON TL.ListID = L.ListID 
				WHERE 	L.NCIViewID = ProdV.NCIViewID
					AND L.NCIViewID IS NOT NULL
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN 
					RAISERROR ( 80006, 16, 1)
					RETURN  
				END 
		
				PRINT '--    (F) Mark all exceptions (List which do not relate to any NCIView directly)' +'<br>'
				UPDATE 	TL 
				SET 	IsNCIViewExistsOnProduction = 'E'
				FROM 	#tmpList AS TL
					INNER JOIN CancerGovStaging..List AS L
					ON TL.ListID = L.ListID 
				WHERE 	L.NCIViewID IS NULL
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN 
					RAISERROR ( 80006, 16, 1)
					RETURN  
				END 
			
				PRINT '--    (G) Find out is the related to ListItem NCIViews exists on production' +'<br>'
				UPDATE 	TLI
				SET 	TLI.IsNCIViewExistsOnProduction = 'Y'
				FROM 	CancerGov..NCIView AS ProdV
					INNER JOIN #tmpListItem AS TLI
					ON TLI.NCIViewID = ProdV.NCIViewID 
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN 
					RAISERROR ( 80006, 16, 1)
					RETURN  
				END 
			
				PRINT '--    (H) Find out are the related to ListItem NCIViews is simple' +'<br>'
				UPDATE 	TLI
			 	SET 	IsSimpleNCIView = 
					CASE 
						WHEN EXISTS(SELECT * FROM CancerGovStaging..ViewObjects AS VO WHERE VO.NCIViewID = TLI.NCIViewID) 
							THEN 'N'
						ELSE 'Y'	
					END
				FROM 	#tmpListItem AS TLI 
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN 
					RAISERROR ( 80006, 16, 1)
					RETURN  
				END 
			
				PRINT '--    (K) Find out are the related to List NCIViews is simple' +'<br>'
				UPDATE 	TL
			 	SET 	IsSimpleNCIView = 
					CASE 
						WHEN EXISTS(SELECT * FROM CancerGovStaging..ViewObjects AS VO WHERE VO.NCIViewID = L.NCIViewID) 
							THEN 'N'
						WHEN L.NCIViewID IS NULL 
							THEN 'E'
						ELSE 'Y'	
					END
				FROM 	#tmpList AS TL 
					INNER JOIN List AS L
					ON L.ListID = TL.ListID
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN 
					RAISERROR ( 80006, 16, 1)
					RETURN  
				END 
			
				PRINT '--  ! (L) Check NCIViews Status related to List records '	+'<br>'
				PRINT '             (For not existed on production NCIViews)'+'<br>'
				IF 	EXISTS(
					SELECT * 
					FROM 	#tmpList AS TL 
						INNER JOIN List AS L 
							ON TL.ListID = L.ListID
							AND TL.Staging = 'Y' 
						INNER JOIN NCIView AS V 
							ON L.NCIViewID = V.NCIViewID
					WHERE 	V.Status NOT IN (@ReadyForProductionStatus, @ProductionStatus)
						AND TL.IsNCIViewExistsOnProduction = 'N'
						AND IsSimpleNCIView = 'N'
					)
					OR 
					EXISTS(
					SELECT * 
					FROM 	#tmpList AS TL 

						INNER JOIN List AS L 
							ON TL.ListID = L.ListID
							AND TL.Staging = 'Y' 
						INNER JOIN NCIView AS V 
							ON L.NCIViewID = V.NCIViewID

					WHERE 	V.Status NOT IN (@ReadyStatusForSimpleNCIView, @ReadyForProductionStatus, @ProductionStatus)
						AND TL.IsNCIViewExistsOnProduction = 'N'
						AND IsSimpleNCIView = 'Y'
					)
				BEGIN
					PRINT '#tmpList table has following items which meet check conditions.' +'<br>'
					SELECT * 
					FROM 	#tmpList AS TL 
						INNER JOIN List AS L 
							ON TL.ListID = L.ListID
						INNER JOIN NCIView AS V 
							ON L.NCIViewID = V.NCIViewID
					WHERE 	V.Status NOT IN (@ReadyForProductionStatus, @ProductionStatus)
						AND TL.IsNCIViewExistsOnProduction = 'N'

					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN 
					RAISERROR ( 80006, 16, 1)
					RETURN  
				END 
			
				PRINT '--  ! (M) Check NCIViews Status related to ListItem records '	+'<br>'
				PRINT '             (For not existed on production NCIViews)' +'<br>'
				IF 	EXISTS( 
					SELECT 	* 
					FROM 	#tmpListItem AS TLI
					WHERE 	Status NOT IN (@ReadyForProductionStatus, @ProductionStatus)
						AND TLI.IsNCIViewExistsOnProduction = 'N'
						AND IsSimpleNCIView = 'N'
						AND TLI.Staging = 'Y' 
					)
					OR
					EXISTS( 
					SELECT 	* 
					FROM 	#tmpListItem AS TLI
					WHERE 	Status NOT IN (@ReadyStatusForSimpleNCIView, @ReadyForProductionStatus, @ProductionStatus)
						AND TLI.IsNCIViewExistsOnProduction = 'N'
						AND IsSimpleNCIView = 'Y'
						AND TLI.Staging = 'Y' 
					)
				BEGIN
					PRINT '#tmpListItem table has following items which meet check conditions.' +'<br>'
					SELECT 	* 
					FROM 	#tmpListItem AS TLI
					WHERE 	Status NOT IN (@ReadyForProductionStatus, @ProductionStatus)
						AND TLI.IsNCIViewExistsOnProduction = 'N'
					
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN 
					RAISERROR ( 80006, 16, 1)
					RETURN  
				END 
				
				PRINT '--    (N) Push Simple NCIViews to Production (if it is ready to go)'	+'<br>'
				--    (B-g) Push Simple NCIViews to Production	
				DECLARE Simple_NCIViews_cursor CURSOR LOCAL FOR 
				SELECT 	NCIViewID
				FROM 	#tmpListItem AS TLI 
				WHERE 	IsSimpleNCIView = 'Y'
					AND Staging = 'Y' 
					AND Status IN ( @ReadyStatusForSimpleNCIView, @ReadyForProductionStatus ) 
				UNION
				SELECT 	L.NCIViewID
				FROM 	#tmpList AS TL
					INNER JOIN CancerGovStaging..List AS L
						ON L.ListID = TL.ListID 
					INNER JOIN CancerGovStaging..NCIView AS SV
						ON SV.NCIViewID = L.NCIViewID
						--AND SV.Status = @ReadyForProductionStatus
						AND SV.Status IN ( @ReadyStatusForSimpleNCIView, @ReadyForProductionStatus ) 
				WHERE 	IsSimpleNCIView = 'Y'
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN 
					RAISERROR ( 80011, 16, 1)
					RETURN  
				END 
				-- Open simple Cursor
				OPEN Simple_NCIViews_cursor
				IF (@@ERROR <> 0)
				BEGIN
					DEALLOCATE Simple_NCIViews_cursor 
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN 
					RAISERROR ( 80011, 16, 1)
					RETURN  
				END 
				FETCH NEXT FROM Simple_NCIViews_cursor INTO @SimpleNCIViewID
				
				WHILE @@FETCH_STATUS = 0
				BEGIN
					PRINT '  --  (N-a) Set Correct Status for NCIView {'+convert(varchar(36), @SimpleNCIViewID)+'} Before Pushing' +'<br>'
					UPDATE 	SV
					SET	Status = @ReadyForProductionStatus 
					FROM 	CancerGovStaging..NCIView AS SV
					WHERE 	NCIViewID = @SimpleNCIViewID
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE Simple_NCIViews_cursor 
						DEALLOCATE Simple_NCIViews_cursor 
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80011, 16, 1)
						RETURN  
					END 
					
					PRINT '  --  (N-b) Push Simple NCIView {'+convert(varchar(36), @SimpleNCIViewID)+'}' +'<br>'
					SELECT @ReturnStatus = 0
					EXECUTE @ReturnStatus = [CancerGovStaging].[dbo].[usp_PushNCIViewToProduction] 
						@NCIViewID = @SimpleNCIViewID,
						@UpdateUserID = @UpdateUserID 
					IF (@@ERROR <> 0)
					     OR 
					    (@ReturnStatus <> 0)
					BEGIN
						CLOSE Simple_NCIViews_cursor 
						DEALLOCATE Simple_NCIViews_cursor 
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80011, 16, 1)
						RETURN  
					END 

					FETCH NEXT FROM Simple_NCIViews_cursor INTO @SimpleNCIViewID
				END
								
				CLOSE Simple_NCIViews_cursor
				DEALLOCATE Simple_NCIViews_cursor
				
				PRINT '--    (O) Check do we have List and ListItem''s records on Production'	+'<br>'
				UPDATE  TL
				SET 	TL.Production = 'Y'
				FROM 	#tmpList AS TL
					INNER JOIN CancerGov..List PL
					ON TL.ListID = PL.ListID
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN 
					RAISERROR ( 80007, 16, 1)
					RETURN  
				END 

				if (@ObjectType ='NLLIST')
				BEGIN			
					UPDATE 	TLI
					SET 	TLI.Production = 'Y'
					FROM 	#tmpListItem AS TLI 
						INNER JOIN CancerGov..NLListItem AS PLI	
							ON TLI.NCIViewID = PLI.NCIViewID
							AND TLI.ListID = PLI.ListID 
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80007, 16, 1)
						RETURN  
					END
				END
				ELSE
				BEGIN	
					UPDATE 	TLI
					SET 	TLI.Production = 'Y'
					FROM 	#tmpListItem AS TLI 
						INNER JOIN CancerGov..ListItem AS PLI	
							ON TLI.NCIViewID = PLI.NCIViewID
							AND TLI.ListID = PLI.ListID 
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80007, 16, 1)
						RETURN  
					END 
				END
			
				PRINT '--    (R) Clear Production from un used ListItems. 2 cases: NLList and others'	+'<br>'
				if (@ObjectType ='NLLIST')
				BEGIN		
					DELETE 	PLI
					FROM 	CancerGov..NLListItem AS PLI
						INNER JOIN #tmpListItem AS TLI
							ON TLI.ListID = PLI.ListID 
							AND TLI.NCIViewID = PLI.NCIViewID
							AND TLI.Staging = 'N' 
							AND TLI.Production = 'Y' 
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80007, 16, 1)
						RETURN  
					END 
				END
				ELSE
				BEGIN		
					DELETE 	PLI
					FROM 	CancerGov..ListItem AS PLI
						INNER JOIN #tmpListItem AS TLI
							ON TLI.ListID = PLI.ListID 
							AND TLI.NCIViewID = PLI.NCIViewID
							AND TLI.Staging = 'N' 
							AND TLI.Production = 'Y' 
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80007, 16, 1)
						RETURN  
					END 
				END
			
				PRINT '--    (S) Clear Production from un used Lists' +'<br>'
				DELETE 	FROM CancerGov..List 				
				WHERE 	ListID IN (SELECT ListID FROM #tmpList WHERE Staging= 'N' AND Production = 'Y')
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN 
					RAISERROR ( 80007, 16, 1)
					RETURN  
				END 
			
				PRINT '--    (T) Update Existing LIST Data On production'	+'<br>'
				-- (Ea) Update Existing LIST Data On production
				UPDATE  Prod
				SET 	Prod.GroupID = Staging.GroupID,
					Prod.ListName = Staging.ListName,
					Prod.ListDesc = Staging.ListDesc,
					Prod.URL = Staging.URL,
					Prod.ParentListID = Staging.ParentListID,
					Prod.NCIViewID = Staging.NCIViewID,
					Prod.Priority = Staging.Priority,
					Prod.UpdateDate = @UpdateDate,
					Prod.UpdateUserID = @UpdateUserID,
					Prod.DescDisplay = Staging.DescDisplay,
					Prod.ReleaseDateDisplay = Staging.ReleaseDateDisplay,
					Prod.ReleaseDateDisplayLoc = Staging.ReleaseDateDisplayLoc
				FROM 	CancerGov..List AS Prod,
					CancerGovStaging..List AS Staging
				WHERE 	Prod.ListID = Staging.ListID
					AND Staging.ListID IN (SELECT ListID FROM #tmpList T WHERE T.Staging = 'Y' AND T.Production = 'Y') 
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN 
					RAISERROR ( 80007, 16, 1)
					RETURN  
				END 
				
				PRINT '--    (U) Update Existing LISTITEM Data On production'	+'<br>'
				-- (Eb) Update Existing LISTITEM Data On production
				IF (@ObjectType ='NLLIST')
				BEGIN
					UPDATE 	Prod
					SET	Prod.NCIViewID = Staging.NCIViewID,
						Prod.Title	= Staging.Title, 
						Prod.ShortTitle	= Staging.ShortTitle,
						Prod.Description	= Staging.Description, 
						Prod.Priority = Staging.Priority,
						Prod.IsFeatured = Staging.IsFeatured,
						Prod.UpdateDate = @UpdateDate,
						Prod.UpdateUserID = @UpdateUserID
					FROM 	CancerGov..NLListItem AS Prod,
						CancerGovStaging..NLListItem AS Staging,
						#tmpListItem AS Tmp	 
					WHERE 	Prod.NCIViewID = Staging.NCIViewID
						AND Prod.ListID = Staging.ListID
						AND Prod.NCIViewID = Tmp.NCIViewID
						AND Prod.ListID = Tmp.ListID	
						AND Tmp.Staging = 'Y'
						AND Tmp.Production = 'Y'
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80007, 16, 1)
						RETURN  
					END
				END
				ELSE 
				BEGIN
					UPDATE 	Prod
					SET	Prod.NCIViewID = Staging.NCIViewID,
						Prod.Priority = Staging.Priority,
						Prod.IsFeatured = Staging.IsFeatured,
						Prod.UpdateDate = @UpdateDate,
						Prod.UpdateUserID = @UpdateUserID
					FROM 	CancerGov..ListItem AS Prod,
						CancerGovStaging..ListItem AS Staging,
						#tmpListItem AS Tmp	 
					WHERE 	Prod.NCIViewID = Staging.NCIViewID
						AND Prod.ListID = Staging.ListID
						AND Prod.NCIViewID = Tmp.NCIViewID
						AND Prod.ListID = Tmp.ListID	
						AND Tmp.Staging = 'Y'
						AND Tmp.Production = 'Y'
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80007, 16, 1)
						RETURN  
					END
				END

				
				PRINT '--    (Y) Insert new LIST to production'	+'<br>'
				-- (Fa) Inser List to production		
				INSERT INTO CancerGov..List (ListID, GroupID, ListName, ListDesc, URL, ParentListID, NCIViewID,
						Priority, UpdateDate, UpdateUserID, DescDisplay, ReleaseDateDisplay, ReleaseDateDisplayLoc )
				SELECT 	ListID,
					GroupID,
					ListName,
					ListDesc,
					URL,
					ParentListID,
					NCIViewID,
					Priority,
					@UpdateDate AS UpdateDate,
					@UpdateUserID AS UpdateUserID,
					DescDisplay, 
					ReleaseDateDisplay, 
					ReleaseDateDisplayLoc
				FROM CancerGovStaging..List	
				WHERE ListID IN (SELECT ListID FROM #tmpList WHERE Production = 'N')
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN 
					RAISERROR ( 80007, 16, 1)
					RETURN  
				END 
				
				PRINT '--    (V) Insert new LISTITEM to production'	+'<br>'
				-- (Fb) Inser LISTITEM to production		
				IF (@ObjectType ='NLLIST')
				BEGIN
					INSERT INTO CancerGov..NLListItem (ListID, NCIViewID, Title, ShortTitle, Description, Priority, IsFeatured, UpdateDate, UpdateUserID)
					SELECT 	SLI.ListID,
						SLI.NCIViewID,
						SLI.Title,
						SLI.ShortTitle,
						SLI.Description, 
						SLI.Priority,
						SLI.IsFeatured,
						@UpdateDate AS UpdateDate,
						@UpdateUserID AS UpdateUserID
					FROM 	CancerGovStaging..NLListItem SLI,
						#tmpListItem TLI
					WHERE SLI.NCIViewID = TLI.NCIViewID 
						AND SLI.ListID = TLI.ListID
						AND TLI.Production = 'N'
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80007, 16, 1)
						RETURN  
					END
				END
				ELSE
 				BEGIN
					INSERT INTO CancerGov..ListItem (ListID, NCIViewID, Priority, IsFeatured, UpdateDate, UpdateUserID)
					SELECT 	SLI.ListID,
						SLI.NCIViewID,
						SLI.Priority,
						SLI.IsFeatured,
						@UpdateDate AS UpdateDate,
						@UpdateUserID AS UpdateUserID
					FROM 	CancerGovStaging..ListItem SLI,
						#tmpListItem TLI
					WHERE SLI.NCIViewID = TLI.NCIViewID 
						AND SLI.ListID = TLI.ListID
						AND TLI.Production = 'N'
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80007, 16, 1)
						RETURN  
					END
				END
			
				PRINT '--    (Z) Clear Temporary tables (prepare for the next object)'	+'<br>'
				-- (Z) Clear Temporary tables
				TRUNCATE TABLE #tmpList	
				TRUNCATE TABLE #tmpListItem	
			END -- Endt of 'LIST' family Handler
			ELSE 
			IF 	@ObjectType = 'IMAGE'
			BEGIN
				PRINT '*** PUSH IMAGE RECORD TO PRODUCTION'+'<br>'

				IF (EXISTS (SELECT * FROM CancerGov..[Image] WHERE  ImageID = @ObjectID))
				BEGIN

					PRINT '--    Upadate Existing Image Record'+'<br>'
					UPDATE 	P
					SET 	P.ImageName = S.ImageName,
						P.ImageSource = S.ImageSource ,
						P.TextSource = S.TextSource ,
						P.Url = S.Url,
						P.Width = S.Width,
						P.Height = S.Height,
						P.ImageAltText = S.ImageAltText, 
						P.Border = S.Border,
						P.UpdateDate = @UpdateDate,
						P.UpdateUserID = @UpdateUserID 
					FROM 	CancerGovStaging..[Image] AS S,
						CancerGov..[Image] AS P  
					WHERE  P.[ImageID] = S.[ImageID] 
						AND S.[ImageID] = @ObjectID
					IF (@@ERROR <> 0) OR (@@ROWCOUNT <> 1)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80007, 16, 1)
						RETURN  
					END 
				
				END

				ELSE BEGIN
					PRINT '--    Insert New Image Record'+'<br>'
					INSERT INTO CancerGov..[Image](ImageID,ImageName,ImageSource,ImageAltText, TextSource,Url,Width,Height,Border,UpdateDate,UpdateUserID)
					SELECT 	ImageID,
						ImageName,
						ImageSource,
						ImageAltText ,
						TextSource,
						Url,
						Width,
						Height,
						Border,
						UpdateDate,
						UpdateUserID
					FROM 	CancerGovStaging..[Image]
					WHERE	[ImageID] = @ObjectID
					IF (@@ERROR <> 0) OR (@@ROWCOUNT <> 1)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80007, 16, 1)
						RETURN  
					END 
				END
			END  -- End of 'IMAGE' Handler
			ELSE 
			IF 	@ObjectType = 'TSTOPIC'
			BEGIN
				PRINT '*** PUSH TOPIC  RECORD TO PRODUCTION'+'<br>'

				IF (EXISTS (SELECT * FROM CancerGov..[TSTopics] WHERE topicID = @ObjectID))
				BEGIN
					PRINT '--    Upadate Existing Topic Record'+'<br>'
					UPDATE 	P
					SET 	P.TopicName = S.TopicName,
						P.TopicSearchTerm  =S.TopicSearchTerm ,
						P.EditableTopicSearchTerm =S.EditableTopicSearchTerm ,
						P.UpdateDate = @UpdateDate,
						P.UpdateUserID = @UpdateUserID 
					FROM 	CancerGovStaging..[TSTopics] AS S,
						CancerGov..[TSTopics] AS P  
					WHERE  P.[TopicID] = S.[TopicID] 
						AND S.[TopicID] = @ObjectID
					IF (@@ERROR <> 0) OR (@@ROWCOUNT <> 1)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80007, 16, 1)
						RETURN  
					END 
				
				END
				ELSE BEGIN
					PRINT '--    Insert New Topic Record'+'<br>'
					INSERT INTO CancerGov..[TSTopics]
					(TopicID, TopicName,  TopicSearchTerm, EditableTopicSearchTerm, UpdateDate,UpdateUserID)
					SELECT 	TopicID,
						TopicName, 
 						TopicSearchTerm, 
						EditableTopicSearchTerm, 
						UpdateDate,
						UpdateUserID
					FROM 	CancerGovStaging..[TSTopics]
					WHERE	[TopicID] = @ObjectID
					IF (@@ERROR <> 0) OR (@@ROWCOUNT <> 1)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80007, 16, 1)
						RETURN  
					END 
				END
			END  -- End of 'IMAGE' Handler
			ELSE 
			IF 	@ObjectType = 'EFormSCode'
			     or  @ObjectType = 'EFormWCode'
			     or  @ObjectType = 'EFormSHelp'
			     or  @ObjectType = 'EFormWHelp' 
			BEGIN
				PRINT '*** PUSH EFORMSEGMENT RECORD TO PRODUCTION'+'<br>'

				IF (EXISTS (SELECT * FROM CancerGov..[EFormsSegments] WHERE  SegmentID = @ObjectID))
				BEGIN
					PRINT '--    Upadate Existing Segments Record'+'<br>'
					UPDATE 	P
					SET 	P.SegmentName = S.SegmentName, 
						P.[SegmentNumber]= S.[SegmentNumber] ,
						P.SegmentInfo = S.SegmentInfo,
						P.SegmentData = S.SegmentData, 
						P.UpdateDate = @UpdateDate,
						P.UpdateUserID = @UpdateUserID 
					FROM 	CancerGovStaging..[EFormsSegments] AS S,
						CancerGov..[EFormsSegments] AS P  
					WHERE  P.[SegmentID] = S.[SegmentID] 
						AND S.[SegmentID] = @ObjectID
					IF (@@ERROR <> 0) OR (@@ROWCOUNT <> 1)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80007, 16, 1)
						RETURN  
					END 
				END
				ELSE BEGIN
					PRINT '--    Insert New Segment Record'+'<br>'
					INSERT INTO 	CancerGov..[EFormsSegments]
					(SegmentID, SegmentName,  SegmentNumber, SegmentInfo, SegmentData, UpdateDate, UpdateUserID)
					SELECT SegmentID, 
						SegmentName,  
						SegmentNumber, 
						SegmentInfo, 
						SegmentData, 
						UpdateDate, 
						UpdateUserID					
					FROM 	CancerGovStaging..[EFormsSegments]
					WHERE	[SegmentID] = @ObjectID
					IF (@@ERROR <> 0) OR (@@ROWCOUNT <> 1)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80007, 16, 1)
						RETURN  
					END 
				END
			END  -- End of 'EFORMSSEGMENTS' Handler
			ELSE 
			IF 	@ObjectType = 'LINK'
			BEGIN
				PRINT '*** PUSH link RECORD TO PRODUCTION'+'<br>'
				PRINT '--    Push Simple NCIViews to Production (if it is ready to go)'	+'<br>'

				--  Push Simple NCIViews which is in Edit/Approved status to Production	
				IF (EXISTS (SELECT * FROM CancerGovStaging..NCIView WHERE  NCIViewID = @ObjectID and NCITemplateID is null and status in ('Approved')) )
				BEGIN
					PRINT '  -- Set Correct Status for NCIView {'+convert(varchar(36), @SimpleNCIViewID)+'} Before Pushing' +'<br>'
					UPDATE 	CancerGovStaging..NCIView
					SET	Status = 'SUBMIT'
					WHERE 	NCIViewID = @ObjectID
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80007, 16, 1)
						RETURN  
					END 
					
					PRINT '  --   Push Simple NCIView {'+convert(varchar(36), @SimpleNCIViewID)+'}' +'<br>'
					SELECT @ReturnStatus = 0
					EXECUTE @ReturnStatus = [CancerGovStaging].[dbo].[usp_PushNCIViewToProduction] 
						@NCIViewID = @ObjectID,
						@UpdateUserID = @UpdateUserID 
					IF (@@ERROR <> 0)
				     	OR 
				    	(@ReturnStatus <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80007, 16, 1)
						RETURN  
					END 
				END
				ELSE IF (EXISTS (SELECT * FROM CancerGovStaging..NCIView WHERE  NCIViewID = @ObjectID and NCITemplateID is null and status in ('EDIT')) )
				BEGIN
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN 
					RAISERROR ( 80015, 16, 1)
					RETURN  
				END
			END  -- End of 'LINK' Handler
			ELSE 
			IF 	@ObjectType = 'ANIMATION'
				     or  @ObjectType = 'AUDIO'
				     or  @ObjectType ='PHOTO'
			BEGIN
				PRINT '*** PUSH externalobject RECORD TO PRODUCTION'+'<br>'

				IF (EXISTS (SELECT * FROM CancerGov..[ExternalObject] WHERE ExternalObjectID = @ObjectID))
				BEGIN
					PRINT '--    Upadate Existing externalobject  Record'+'<br>'
					UPDATE 	P
					SET 	P.Title= S.Title,
						P.Path =S.Path, 
						P.[Format]=S.[Format],
						P.[Text]	= S.[Text],
						P.[Description] = S.[Description],
						P.UpdateDate = @UpdateDate,
						P.UpdateUserID = @UpdateUserID 
					FROM 	CancerGovStaging..[ExternalObject] AS S,
						CancerGov..[ExternalObject] AS P  
					WHERE  P.[ExternalObjectID] = S.[ExternalObjectID] 
						AND S.[ExternalObjectID] = @ObjectID
					IF (@@ERROR <> 0) OR (@@ROWCOUNT <> 1)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80007, 16, 1)
						RETURN  
					END 
				
				END
				ELSE BEGIN
					PRINT '--    Insert New Topic Record'+'<br>'
					INSERT INTO CancerGov..[ExternalObject]
					(ExternalObjectID, Title, Path,  [Format], [Text], [Description], UpdateDate,UpdateUserID)
					SELECT 	
					ExternalObjectID, Title, Path,  [Format], [Text], [Description],  UpdateDate,UpdateUserID
					FROM 	CancerGovStaging..[ExternalObject]
					WHERE	ExternalObjectID= @ObjectID
					IF (@@ERROR <> 0) OR (@@ROWCOUNT <> 1)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80007, 16, 1)
						RETURN  
					END 
				END
			END  -- End of 'ExternalObject' Handler
			ELSE 
			IF 	@ObjectType = 'NLSECTION'
			BEGIN
				PRINT '*** PUSH NLSection RECORD TO PRODUCTION'+'<br>'

				IF (EXISTS (SELECT * FROM CancerGov..NLSection WHERE NLSectionID = @ObjectID))
				BEGIN
					PRINT '--    Upadate Existing NLSection Record'+'<br>'
					UPDATE 	P
					SET 	P.Title= S.Title,
						P.ShortTitle 	= S.ShortTitle,
						P.PlainBody 	= S.PlainBody, 
						P.HTMLBody 	= S.HTMLBody,
						P.[Description] 	= S.[Description],
						P.UpdateDate 	= @UpdateDate,
						P.UpdateUserID = @UpdateUserID 
					FROM 	CancerGovStaging..NLSection AS S,
						CancerGov..NLSection AS P  
					WHERE  P.NLSectionID = S.NLSectionID
						AND S.NLSectionID = @ObjectID
					IF (@@ERROR <> 0) OR (@@ROWCOUNT <> 1)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80007, 16, 1)
						RETURN  
					END 
				END
				ELSE BEGIN
					PRINT '--    Insert New Topic Record'+'<br>'
					INSERT INTO CancerGov..NLSection
					(NLSectionID, Title, ShortTitle, [Description], HTMLBody, PlainBody,  UpdateDate,UpdateUserID)
					SELECT 	
					NLSectionID, Title, ShortTitle,  [Description], HTMLBody, PlainBody,   UpdateDate,UpdateUserID
					FROM 	CancerGovStaging..NLSection
					WHERE	NLSectionID= @ObjectID
					IF (@@ERROR <> 0) OR (@@ROWCOUNT <> 1)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 80007, 16, 1)
						RETURN  
					END 
				END
			END  -- End of 'NLSection'
			ELSE 
			IF 	@ObjectType ='INFOBOX'
			BEGIN
				Print 'Push InfoBox to production ' + convert(varchar(36), @ObjectID)

				EXEC  	@return_status= usp_PushInfoBoxToProduction @ObjectID, @UpdateUserID  
						
				PRINT '--	return value=' + Convert(varchar(6), @return_status)
				IF (@returnStatus <> 0)
				BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
				END 	
			END
			ELSE BEGIN
				-- All other types handle there
				-- SUMMARY, INCLUDE, XMLINCLUDE, SUMMARY, TXTINCLUDE, PDF  
				-- NEWSCENTER, LIVEHELP
				SELECT @tmpStr = '**** Object with type "' + RTRIM(@ObjectType) + '" will not be pushet to production. Only record about that object in ViewObjects table will be updated.'
				PRINT  @tmpStr 
			END -- End Handler for objects

			-- Insert or update viewobjects. Changed from the bottom part. (update or insert vo one by one) 08-15-2003 Jay He
		
			if (exists (select * from CancerGov..ViewObjects where NCIViewObjectID = @NCIViewObjectID) )
			BEGIN
				PRINT '--    Update existing View Object with new type and Priority'+'<br>'
				UPDATE 	Prod
				SET	Prod.ObjectID = Staging.ObjectID,
					Prod.Type = Staging.Type,
					Prod.Priority = Staging.Priority,
					Prod.UpdateDate = @UpdateDate,
					Prod.UpdateUserID = @UpdateUserID
				FROM 	CancerGov..ViewObjects Prod,
					CancerGovStaging..ViewObjects Staging
				WHERE 	Prod.NCIViewObjectID  = Staging.NCIViewObjectID  
					AND Staging.NCIViewObjectID  = @NCIViewObjectID
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN 
					RAISERROR ( @return_status, 16, 1)
					RETURN  
				END
			END 
			ELSE
			BEGIN	
				PRINT '--    Insert new ViewObjects records'+'<br>'
				INSERT INTO CancerGov..ViewObjects 
				(NCIViewObjectID,NCIViewID,ObjectID,Type,Priority,UpdateDate,UpdateUserID)
				SELECT 	S.NCIViewObjectID,
					S.NCIViewID,
					S.ObjectID,
					S.Type,
					S.Priority,
					@UpdateDate AS UpdateDate,
					@UpdateUserID AS UpdateUserID
				FROM 	CancerGovStaging..ViewObjects S
				WHERE 	NCIViewObjectID= @NCIViewObjectID
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN 
					RAISERROR ( @return_status, 16, 1)
					RETURN  
				END 	
			END
			/* 
			*   Delete all realted parentlist/list/listitem of DigestDocListID
			*   Delete all related viewobjectproperty on CancerGov, which is not on CancerGovStaging.
			*   Insert all realted VOP on CancerGov, which is on CGS
			*   If type = Document and VOP name =DigestDocListID, then push related parentlist/list/listitem to production
			*   using a separate stored proc usp_pushDigestDocListToProduction --- Jay He 08/14/2003
			*/
			PRINT '*** Update ViewObjectProperty'		+'<br>'
			if ((@ObjectType ='DOCUMENT') and exists (Select PropertyValue from CancerGov..ViewObjectProperty Where NCIViewObjectID = @NCIViewObjectID and PropertyName ='DigestRelatedListID'))
			BEGIN
				Print 'Delete DigestDocListID related parentlist/list/listitem to production'
				EXEC  	@return_status= usp_DeleteDigestDocListForProduction @ObjectID 
						
				PRINT '--	return value=' + Convert(varchar(60), @return_status)
				IF @return_status <> 0
				BEGIN
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN 
					RAISERROR ( @return_status, 16, 1)
					RETURN  
				END 	
			END

			PRINT '--    Delete ViewObjectProperty records from production for this nciviewobjectid --'+  convert(varchar(36), @NCIViewObjectID)  + '--<br>'
			DELETE
			FROM 	CancerGov..ViewObjectProperty
			WHERE 	NCIViewObjectId = @NCIViewObjectID 
			IF (@@ERROR <> 0)
			BEGIN
				CLOSE ViewObject_Cursor 
				DEALLOCATE ViewObject_Cursor 
				ROLLBACK TRAN 
				RAISERROR ( 80110, 16, 1)
				RETURN  
			END 

			PRINT '--    Insert updated ViewObjectProperty records to production --'+ convert(varchar(36), @NCIViewObjectID) + '--<br>'
			INSERT INTO CancerGov..ViewObjectProperty ( NCIViewObjectID, PropertyName, PropertyValue, UpdateDate, UpdateUserID)
			SELECT 	NCIViewObjectID, PropertyName, PropertyValue, UpdateDate, UpdateUserID
			FROM 	CancerGovStaging..ViewObjectProperty 
			WHERE 	NCIViewObjectId = @NCIViewObjectID 
			IF (@@ERROR <> 0)
			BEGIN
				CLOSE ViewObject_Cursor 
				DEALLOCATE ViewObject_Cursor 
				ROLLBACK TRAN 
				RAISERROR ( 80111, 16, 1)
				RETURN  
			END 

			-- If it is a Document and has DigestDocListID. If catch error, return error 80100+
			if ((@ObjectType ='DOCUMENT') and exists (Select PropertyValue from CancerGovStaging..ViewObjectProperty Where NCIViewObjectID = @NCIViewObjectID and PropertyName ='DigestRelatedListID'))
			BEGIN

				Print 'Push DigestDocListID related parentlist/list/listitem to production'
				EXEC  	@return_status= usp_PushDigestDocListToProduction @NCIViewObjectID, @UpdateUserID  
						
				PRINT '--	return value=' + Convert(varchar(6), @return_status)
				IF @return_status <> 0
				BEGIN
					CLOSE ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN 
					RAISERROR ( @return_status,  16, 1)
					RETURN  
				END 	
			END


			PRINT '**** GET NEXT OBJECT'	+'<br>'
			-- GET NEXT OBJECT
			FETCH NEXT FROM ViewObject_Cursor
			INTO 	@NCIViewObjectID, @ObjectID, @ObjectType	
		END
		PRINT '*** CLOSE ViewObject_Cursor'		+'<br>'

		-- CLOSE ViewObject_Cursor		
		CLOSE ViewObject_Cursor 
		DEALLOCATE ViewObject_Cursor 
	

		-- Add a condition for distinguishing eform and other templates. If eform, do nothing here.

		IF NOT EXISTS (SELECT * FROM CancerGov..NCITemplate T, CancerGov..NCIView N WHERE N.NCITemplateID =T.NCITemplateID AND N.NCIViewID = @NCIViewID and T.Name= 'EFORM' )
		BEGIN
			PRINT '--    Delete unused ViewObjects records from production'+'<br>'
			DELETE 	CancerGov..ViewObjects 
			FROM 	CancerGov..ViewObjects 
			WHERE 	NCIViewID = @NCIViewID
				AND NCIViewObjectId NOT IN (
						SELECT NCIViewObjectId 
						FROM CancerGovStaging..ViewObjects 
						WHERE NCIViewID = @NCIViewID
						)
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN 
				RAISERROR ( 80008, 16, 1)
				RETURN  
			END
		END 


		PRINT 'COMMIT TRAN Tran_PushNCIViewToProduction'		+'<br>'
		COMMIT TRAN Tran_PushNCIViewToProduction
	END --End IF - NCIView was APPROVED 
	ELSE BEGIN
		-- NCI View {%s} not in %s status. View cannot be pushed to production environment.
		DROP TABLE #tmpList
		DROP TABLE #tmpListItem
		SELECT 	@tmpStr = CONVERT(varchar(36), @NCIViewID),
			@tmpStr1 = @ReadyForProductionStatus + ' or ' + @ReadyStatusForSimpleNCIView

		IF (@IsSimple = 'N') RAISERROR ( 80012, 16, 1, @tmpStr , @ReadyForProductionStatus)
		ELSE RAISERROR ( 80012, 16, 1, @tmpStr , @tmpStr1 )

		RETURN 
	END

	PRINT '***********************************************************************************************************'+'<br>'
	PRINT 'FINISH'+'<br>'

	PRINT '***********************************************************************************************************'+'<br>'

	DROP TABLE #tmpList

	DROP TABLE #tmpListItem
	SET NOCOUNT OFF
	RETURN 0

END



GO
GRANT EXECUTE ON [dbo].[usp_PushNCIViewToProduction] TO [gatekeeper_role]
GO
GRANT EXECUTE ON [dbo].[usp_PushNCIViewToProduction] TO [webadminuser_role]
GO
