IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_PopulateProtocolStudyContact]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_PopulateProtocolStudyContact]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
**  This procedure will create exactly same records in the HotfixprotocolStudyContact table
**
**  Author: Jay He 04-01-02
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
CREATE PROCEDURE [dbo].[usp_PopulateProtocolStudyContact]
	(
	@ProtocolID uniqueidentifier,   -- this is the guid for Protocol 
	@UpdateUserID varchar(50)   -- This should be the username 
	)
AS
BEGIN	
	SET NOCOUNT ON

	DECLARE @ActivePDQ 	varchar(50),
		@PersonID 	 	uniqueidentifier,
		@OrganizationID	uniqueidentifier,
		@CountryID	 	uniqueidentifier,
		@StateID		uniqueidentifier,
		@Country		varchar(50), 
		@State			varchar(50), 
		@City			varchar(50), 
		@OrganizationName	varchar(256), 
		@PersonName		varchar(100), 
		@PhoneNumber		varchar(50), 
		@OrgInfo		varchar(500), 
		@UpdateDate 		datetime
	

	SELECT @UpdateDate = GETDATE()
	/*
	** STEP - A
	** First get the valid PDQ database
	** if not return a 70001 error
	*/		
	Select top 1 @ActivePDQ = ActivePDQ from PDQActiveFlag 
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN  Tran_CreateHotfixStudyContact
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	/*
	** STEP - B
	** First Validate that the protocol guid provided is valid
	** if not return a 70001 error
	*/	
	if @ActivePDQ ='PDQ1'	
	BEGIN
		if(	
		  (@ProtocolID IS NULL) OR (NOT EXISTS (SELECT ProtocolID FROM PDQOne..Protocol WHERE  ProtocolID = @ProtocolID)) 
		  )	
		BEGIN
			RAISERROR ( 70001, 16, 1)
			RETURN 70001
		END

		BEGIN  TRAN   Tran_CreateHotfixStudyContact
		/*
		** STEP - B
		** Loop through all objects in the ProtocolStudyContact Table and create  each one in hotfix table
		** if not return a 70004 error
		*/
		BEGIN
			DECLARE StudyContact_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
				SELECT  PersonID, OrganizationID,CountryID,StateID,Country,State,City,OrganizationName,PersonName,PhoneNumber,OrgInfo
				FROM 		PDQOne..ProtocolStudyContact
				WHERE  	ProtocolID = @ProtocolID
			For Read Only
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		
			OPEN StudyContact_Cursor 
			IF (@@ERROR <> 0)
			BEGIN
				DEALLOCATE StudyContact_Cursor 
				ROLLBACK TRAN Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)		
				RETURN 70004
			END 
		
			FETCH NEXT FROM StudyContact_Cursor
			INTO @PersonID, @OrganizationID,@CountryID,@StateID,@Country,@State,@City,@OrganizationName,@PersonName,@PhoneNumber, @OrgInfo	

			WHILE @@FETCH_STATUS = 0
			BEGIN
				insert into CancerGovStaging..HotFixProtocolStudyContact
				( ProtocolID, PersonID, OrganizationID,CountryID,StateID,Country,State,City,OrganizationName,PersonName,PhoneNumber,OrgInfo, UpdateDate, UpdateUserID)
				values
				(@ProtocolID, @PersonID, @OrganizationID,@CountryID,@StateID,@Country,@State,@City,@OrganizationName,@PersonName,@PhoneNumber,@OrgInfo,@UpdateDate, @UpdateUserID)
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE StudyContact_Cursor 
					DEALLOCATE StudyContact_Cursor
					ROLLBACK TRAN   Tran_CreateHotfixStudyContact
					RAISERROR ( 70006, 16, 1)
					RETURN  70006
				END 
	
				-- GET NEXT OBJECT
				FETCH NEXT FROM StudyContact_Cursor
				INTO @PersonID, @OrganizationID,@CountryID,@StateID,@Country,@State,@City,@OrganizationName,@PersonName,@PhoneNumber, @OrgInfo		

			END -- End while
	
			-- CLOSE ViewObject_Cursor		
			CLOSE StudyContact_Cursor
			DEALLOCATE StudyContact_Cursor
		END  
		COMMIT TRAN   Tran_CreateHotfixStudyContact

	END
	ELSE
	BEGIN
		if(	
		  (@ProtocolID IS NULL) OR (NOT EXISTS (SELECT ProtocolID FROM PDQTwo..Protocol WHERE  ProtocolID = @ProtocolID)) 
		  )	
		BEGIN
			RAISERROR ( 70001, 16, 1)
			RETURN 70001
		END	

		BEGIN  TRAN   Tran_CreateHotfixStudyContact
		/*
		** STEP - B
		** Loop through all objects in the ProtocolStudyContact Table and create  each one in hotfix table
		** if not return a 70004 error
		*/
		BEGIN
			DECLARE StudyContact_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
				SELECT  PersonID, OrganizationID,CountryID,StateID,Country,State,City,OrganizationName,PersonName,PhoneNumber,OrgInfo
				FROM 		PDQTwo..ProtocolStudyContact
				WHERE  	ProtocolID = @ProtocolID
			For Read Only
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
			
			OPEN StudyContact_Cursor
			IF (@@ERROR <> 0)
			BEGIN
				DEALLOCATE StudyContact_Cursor 
				ROLLBACK TRAN Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)		
				RETURN 70004
			END 
		
			FETCH NEXT FROM StudyContact_Cursor
			INTO @PersonID, @OrganizationID,@CountryID,@StateID,@Country,@State,@City,@OrganizationName,@PersonName,@PhoneNumber, @OrgInfo	
	
			WHILE @@FETCH_STATUS = 0
			BEGIN
				insert into CancerGovStaging..HotFixProtocolStudyContact
				( ProtocolID, PersonID, OrganizationID,CountryID,StateID,Country,State,City,OrganizationName,PersonName,PhoneNumber,OrgInfo, UpdateDate, UpdateUserID)
				values
				(@ProtocolID, @PersonID, @OrganizationID,@CountryID,@StateID,@Country,@State,@City,@OrganizationName,@PersonName,@PhoneNumber,@OrgInfo,@UpdateDate, @UpdateUserID)
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE StudyContact_Cursor 
					DEALLOCATE StudyContact_Cursor
					ROLLBACK TRAN   Tran_CreateHotfixStudyContact
					RAISERROR ( 70006, 16, 1)
					RETURN  70006
				END 
	
				-- GET NEXT OBJECT
				FETCH NEXT FROM StudyContact_Cursor
				INTO @PersonID, @OrganizationID,@CountryID,@StateID,@Country,@State,@City,@OrganizationName,@PersonName,@PhoneNumber, @OrgInfo		
	
			END -- End while
	
			-- CLOSE ViewObject_Cursor		
			CLOSE StudyContact_Cursor
			DEALLOCATE StudyContact_Cursor
		END  
		COMMIT TRAN   Tran_CreateHotfixStudyContact
	END

	SET NOCOUNT OFF
	RETURN 0 
END
GO
