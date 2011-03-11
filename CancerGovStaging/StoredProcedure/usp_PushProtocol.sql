IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_PushProtocol]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_PushProtocol]
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
CREATE PROCEDURE [dbo].[usp_PushProtocol]
	(
	@ProtocolID 		uniqueidentifier,  -- this is the guid for Protocol 
	@UpdateUserID		varchar(50)
	)
AS
BEGIN	
	SET NOCOUNT ON

	DECLARE @ActivePDQ 	varchar(50),     -- Get active PDQ where the hotfix data should go
		@Title			varchar(2000),  -- For protocol table hotfix
		@ShortTitle		varchar(2000),  -- for protocol table hotfix
		@Abstract		varchar(5000),  --for protocoldata table hotfix
		@DosageForms		varchar(5000),  --
		@DosageSchedule	varchar(5000),	--
		@EndPoints		varchar(5000),	--
		@EntryCriteria		varchar(5000),	--
		@Objectives		varchar(5000),	--
		@Outline		varchar(5000),	--
		@ProjectedAccrual	varchar(5000),	--
		@SpeciaStudyParameters	varchar(5000),
		@Stratification		varchar(5000),	--
		@Warning		varchar(5000),	-- for protocoldata table hotfix
		@PersonID 	 	uniqueidentifier,	-- for protocolstudycontact table hotfix
		@OrganizationID	uniqueidentifier,	--
		@CountryID	 	uniqueidentifier,	--
		@StateID		uniqueidentifier,	--
		@Country		varchar(50), 
		@State			varchar(50), 
		@City			varchar(50), 
		@OrganizationName	varchar(256), 
		@PersonName		varchar(100), 
		@PhoneNumber		varchar(50), 
		@OrgInfo		varchar(500),	 -- for protocolstudycontact table hotfix
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
		
	BEGIN  TRAN   Tran_CreateHotfixStudyContact
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

		/*
		** STEP - PDQ1 -- A
		** select all from the Protocol Table and update each one with hotfix table
		** if not return a 70004 error
		*/
		SELECT @Title		= Title, 
			@ShortTitle	= ShortTitle, 
			@Abstract	= Abstract,
			@DosageForms		= DosageForms,
			@DosageSchedule	= DosageSchedule,
			@EndPoints		= EndPoints,	
			@EntryCriteria		=EntryCriteria,	
			@Objectives		=Objectives,	
			@Outline		=Outline,	
			@ProjectedAccrual	=ProjectedAccrual,	
			@SpeciaStudyParameters	=SpeciaStudyParameters	,
			@Stratification		=Stratification,	
			@Warning		=Warning	
		FROM CancerGovStaging..HotFixProtocol
		WHERE ProtocolID =@ProtocolID

		Update  PDQOne..Protocol 
		set	Title		=@Title,	
			ShortTitle	=@ShortTitle
		WHERE 	ProtocolID = @ProtocolID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_CreateHotfixStudyContact
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

	
		if LEN(@Abstract) <> 0		
		BEGIN
			if (exists (select protocolID FROM PDQOne..ProtocolData PD,  Type T where PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='abstract' ))
			BEGIN
				Update 	PD
				set 	PD.Data =@Abstract
				FROM  	PDQOne..ProtocolData PD,  Type T
				where 	PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='abstract'
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN  Tran_CreateHotfixStudyContact
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END
			END
		END
		else
		BEGIN
			delete 	FROM  	PDQOne..ProtocolData 
			where 	ProtocolID =@ProtocolID and Type = (select  TypeID from  Type where Name ='abstract')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		if LEN(@EntryCriteria) <> 0		
		BEGIN
			if (exists (select protocolID FROM PDQOne..ProtocolData PD,  Type T where PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='entry criteria' ))
			BEGIN
				Update 	PD
				set 	PD.Data =@EntryCriteria
				FROM  	PDQOne..ProtocolData PD,  Type T
				where 	PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='entry criteria'
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN  Tran_CreateHotfixStudyContact
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END
			END
		END
		else
		BEGIN
			delete 	FROM  	PDQOne..ProtocolData 
			where 	ProtocolID =@ProtocolID and Type = (select  TypeID from  Type where Name ='entry criteria')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		if LEN(@DosageSchedule) <> 0		
		BEGIN
			if (exists (select protocolID FROM PDQOne..ProtocolData PD,  Type T where PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='dosage schedule' ))
			BEGIN
				Update 	PD
				set 	PD.Data =@DosageSchedule	
				FROM  	PDQOne..ProtocolData PD,  Type T
				where 	PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='dosage schedule'
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN  Tran_CreateHotfixStudyContact
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END 
			END
		END
		else
		BEGIN
			delete 	FROM  	PDQOne..ProtocolData 
			where 	ProtocolID =@ProtocolID and Type = (select  TypeID from  Type where Name ='dosage schedule')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		if LEN(@ProjectedAccrual) <> 0		
		BEGIN
			if (exists (select protocolID FROM PDQOne..ProtocolData PD,  Type T where PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='projected accrual' ))
			BEGIN
				Update 	PD
				set 	PD.Data =@ProjectedAccrual	
				FROM  	PDQOne..ProtocolData PD,  Type T
				where 	PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='projected accrual'
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN  Tran_CreateHotfixStudyContact
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END
			END 
		END
		else
		BEGIN
			delete 	FROM  	PDQOne..ProtocolData 
			where 	ProtocolID =@ProtocolID and Type = (select  TypeID from  Type where Name ='projected accrual')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		if LEN(@DosageForms)	 <> 0		
		BEGIN
			if (exists (select protocolID FROM PDQOne..ProtocolData PD,  Type T where PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='dosage forms' ))
			BEGIN
				Update 	PD
				set 	PD.Data =@DosageForms	
				FROM  	PDQOne..ProtocolData PD,  Type T
				where 	PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='dosage forms'
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN  Tran_CreateHotfixStudyContact
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END
			END 
		END
		else
		BEGIN
			delete 	FROM  	PDQOne..ProtocolData 
			where 	ProtocolID =@ProtocolID and Type = (select  TypeID from  Type where Name ='dosage forms')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		if LEN(@EndPoints) <> 0		
		BEGIN
			if (exists (select protocolID FROM PDQOne..ProtocolData PD,  Type T where PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='end points'))
			BEGIN
				Update 	PD
				set 	PD.Data =@EndPoints
				FROM  	PDQOne..ProtocolData PD,  Type T
				where 	PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='end points'
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN  Tran_CreateHotfixStudyContact
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END
			END 
		END
		else
		BEGIN
			delete 	FROM  	PDQOne..ProtocolData 
			where 	ProtocolID =@ProtocolID and Type = (select  TypeID from  Type where Name ='end points')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		if LEN(@Objectives) <> 0		
		BEGIN
			if (exists (select protocolID FROM PDQOne..ProtocolData PD,  Type T where PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='objectives'))
			BEGIN
				Update 	PD
				set 	PD.Data =@Objectives	
				FROM  	PDQOne..ProtocolData PD,  Type T
				where 	PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='objectives'
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN  Tran_CreateHotfixStudyContact
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END
			END 
		END
		else
		BEGIN
			delete 	FROM  	PDQOne..ProtocolData 
			where 	ProtocolID =@ProtocolID and Type = (select  TypeID from  Type where Name ='end points')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		if LEN(@Stratification) <> 0		
		BEGIN
			if (exists (select protocolID FROM PDQOne..ProtocolData PD,  Type T where PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='stratification'))
			BEGIN
				Update 	PD
				set 	PD.Data =@Stratification	
				FROM  	PDQOne..ProtocolData PD,  Type T
				where 	PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='stratification'
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN  Tran_CreateHotfixStudyContact
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END
			END 
		END
		else
		BEGIN
			delete 	FROM  	PDQOne..ProtocolData 
			where 	ProtocolID =@ProtocolID and Type = (select  TypeID from  Type where Name ='stratification')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		if LEN(@Warning) <> 0		
		BEGIN
			if (exists (select protocolID FROM PDQOne..ProtocolData PD,  Type T where PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='warning'))
			BEGIN
				Update 	PD
				set 	PD.Data =@Warning	
				FROM  	PDQOne..ProtocolData PD,  Type T
				where 	PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='warning'
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN  Tran_CreateHotfixStudyContact
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END
			END 
		END
		else
		BEGIN
			delete 	FROM  	PDQOne..ProtocolData 
			where 	ProtocolID =@ProtocolID and Type = (select  TypeID from  Type where Name ='warning')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		if LEN(@Outline) <> 0		
		BEGIN
			if (exists (select protocolID FROM PDQOne..ProtocolData PD,  Type T where PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='outline'))
			BEGIN
				Update 	PD
				set 	PD.Data =@Outline
				FROM  	PDQOne..ProtocolData PD,  Type T
				where 	PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='outline'
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN  Tran_CreateHotfixStudyContact
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END
			END 
		END
		else
		BEGIN
			delete 	FROM  	PDQOne..ProtocolData 
			where 	ProtocolID =@ProtocolID and Type = (select  TypeID from  Type where Name ='outline')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		if LEN(@SpeciaStudyParameters) <> 0		
		BEGIN
			if (exists (select protocolID FROM PDQOne..ProtocolData PD,  Type T where PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='special study parameters'))
			BEGIN
				Update 	PD
				set 	PD.Data =@SpeciaStudyParameters
				FROM  	PDQOne..ProtocolData PD,  Type T
				where 	PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='special study parameters'
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN  Tran_CreateHotfixStudyContact
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END
			END 
		END
		else
		BEGIN
			delete 	FROM  	PDQOne..ProtocolData 
			where 	ProtocolID =@ProtocolID and Type = (select  TypeID from  Type where Name ='special study parameters')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		if ( EXISTS (SELECT ProtocolID FROM CancerGovStaging..HotFixProtocolStudyContact WHERE  ProtocolID = @ProtocolID))
		BEGIN
			Delete from PDQOne..ProtocolStudyContact
			where 	ProtocolID =@ProtocolID
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
			
			/*
			** STEP - B
			** Loop through all objects in the ProtocolStudyContact Table and update  each one in hotfix table
			** if not return a 70004 error  PDQOne..ProtocolStudyContact
			*/
			BEGIN
				DECLARE StudyContact_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
					SELECT  PersonID, OrganizationID,CountryID,StateID,Country,State,City,OrganizationName,PersonName,PhoneNumber,OrgInfo
					FROM 		HotFixProtocolStudyContact
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
					insert into PDQOne..ProtocolStudyContact
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
		END
	END
	ELSE  -- PDQ2 -- 
	BEGIN
		if(	
		  (@ProtocolID IS NULL) OR (NOT EXISTS (SELECT ProtocolID FROM PDQTwo..Protocol WHERE  ProtocolID = @ProtocolID)) 
		  )	
		BEGIN
			RAISERROR ( 70001, 16, 1)
			RETURN 70001
		END

		/*
		** STEP - PDQ1 -- A
		** select all from the Protocol Table and update each one with hotfix table
		** if not return a 70004 error
		*/
		SELECT @Title		= Title, 
			@ShortTitle	= ShortTitle, 
			@Abstract	= Abstract,
			@DosageForms		= DosageForms,
			@DosageSchedule	= DosageSchedule,
			@EndPoints		= EndPoints,	
			@EntryCriteria		=EntryCriteria,	
			@Objectives		=Objectives,	
			@Outline		=Outline,	
			@ProjectedAccrual	=ProjectedAccrual,	
			@SpeciaStudyParameters	=SpeciaStudyParameters	,
			@Stratification		=Stratification,	
			@Warning		=Warning	
		FROM CancerGovStaging..HotFixProtocol
		WHERE ProtocolID =@ProtocolID

		Update  PDQTwo..Protocol 
		set	Title		=@Title,	
			ShortTitle	=@ShortTitle
		WHERE 	ProtocolID = @ProtocolID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_CreateHotfixStudyContact
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

	
		if LEN(@Abstract) <> 0		
		BEGIN
			if (exists (select protocolID FROM PDQTwo..ProtocolData PD,  Type T where PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='abstract' ))
			BEGIN
				Update 	PD
				set 	PD.Data =@Abstract
				FROM  	PDQTwo..ProtocolData PD,  Type T
				where 	PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='abstract'
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN  Tran_CreateHotfixStudyContact
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END
			END
		END
		else
		BEGIN
			delete 	FROM  	PDQTwo..ProtocolData 
			where 	ProtocolID =@ProtocolID and Type = (select  TypeID from  Type where Name ='abstract')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		if LEN(@EntryCriteria) <> 0		
		BEGIN
			if (exists (select protocolID FROM PDQTwo..ProtocolData PD,  Type T where PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='entry criteria' ))
			BEGIN
				Update 	PD
				set 	PD.Data =@EntryCriteria
				FROM  PDQTwo..ProtocolData PD,  Type T
				where 	PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='entry criteria'
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN  Tran_CreateHotfixStudyContact
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END
			END
		END
		else
		BEGIN
			delete 	FROM  	PDQTwo..ProtocolData 
			where 	ProtocolID =@ProtocolID and Type = (select  TypeID from  Type where Name ='entry criteria')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		if LEN(@DosageSchedule) <> 0		
		BEGIN
			if (exists (select protocolID FROM PDQTwo..ProtocolData PD,  Type T where PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='dosage schedule' ))
			BEGIN
				Update 	PD
				set 	PD.Data =@DosageSchedule	
				FROM  PDQTwo..ProtocolData PD,  Type T
				where 	PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='dosage schedule'
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN  Tran_CreateHotfixStudyContact
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END 
			END
		END
		else
		BEGIN
			delete 	FROM  	PDQTwo..ProtocolData 
			where 	ProtocolID =@ProtocolID and Type = (select  TypeID from  Type where Name ='dosage schedule')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		if LEN(@ProjectedAccrual) <> 0		
		BEGIN
			if (exists (select protocolID FROM PDQTwo..ProtocolData PD,  Type T where PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='projected accrual' ))
			BEGIN
				Update 	PD
				set 	PD.Data =@ProjectedAccrual	
				FROM  	PDQTwo..ProtocolData PD,  Type T
				where 	PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='projected accrual'
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN  Tran_CreateHotfixStudyContact
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END
			END 
		END
		else
		BEGIN
			delete 	FROM  	PDQTwo..ProtocolData 
			where 	ProtocolID =@ProtocolID and Type = (select  TypeID from  Type where Name ='projected accrual')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		if LEN(@DosageForms)	 <> 0		
		BEGIN
			if (exists (select protocolID FROM PDQTwo..ProtocolData PD,  Type T where PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='dosage forms' ))
			BEGIN
				Update 	PD
				set 	PD.Data =@DosageForms	
				FROM  	PDQTwo..ProtocolData PD,  Type T
				where 	PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='dosage forms'
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN  Tran_CreateHotfixStudyContact
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END
			END 
		END
		else
		BEGIN
			delete 	FROM  	PDQTwo..ProtocolData 
			where 	ProtocolID =@ProtocolID and Type = (select  TypeID from  Type where Name ='dosage forms')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		if LEN(@EndPoints) <> 0		
		BEGIN
			if (exists (select protocolID FROM PDQTwo..ProtocolData PD,  Type T where PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='end points'))
			BEGIN
				Update 	PD
				set 	PD.Data =@EndPoints
				FROM  	PDQTwo..ProtocolData PD,  Type T
				where 	PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='end points'
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN  Tran_CreateHotfixStudyContact
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END
			END 
		END
		else
		BEGIN
			delete 	FROM  	PDQTwo..ProtocolData 
			where 	ProtocolID =@ProtocolID and Type = (select  TypeID from  Type where Name ='end points')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		if LEN(@Objectives) <> 0		
		BEGIN
			if (exists (select protocolID FROM PDQTwo..ProtocolData PD,  Type T where PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='objectives'))
			BEGIN
				Update 	PD
				set 	PD.Data =@Objectives	
				FROM  	PDQTwo..ProtocolData PD,  Type T
				where 	PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='objectives'
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN  Tran_CreateHotfixStudyContact
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END
			END 
		END
		else
		BEGIN
			delete 	FROM  PDQTwo..ProtocolData 
			where 	ProtocolID =@ProtocolID and Type = (select  TypeID from  Type where Name ='end points')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		if LEN(@Stratification) <> 0		
		BEGIN
			if (exists (select protocolID FROM PDQTwo..ProtocolData PD,  Type T where PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='stratification'))
			BEGIN
				Update 	PD
				set 	PD.Data =@Stratification	
				FROM  PDQTwo..ProtocolData PD,  Type T
				where 	PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='stratification'
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN  Tran_CreateHotfixStudyContact
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END
			END 
		END
		else
		BEGIN
			delete 	FROM  	PDQTwo..ProtocolData 
			where 	ProtocolID =@ProtocolID and Type = (select  TypeID from  Type where Name ='stratification')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		if LEN(@Warning) <> 0		
		BEGIN
			if (exists (select protocolID FROM PDQTwo..ProtocolData PD,  Type T where PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='warning'))
			BEGIN
				Update 	PD
				set 	PD.Data =@Warning	
				FROM  	PDQTwo..ProtocolData PD,  Type T
				where 	PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='warning'
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN  Tran_CreateHotfixStudyContact
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END
			END 
		END
		else
		BEGIN
			delete 	FROM  	PDQTwo..ProtocolData 
			where 	ProtocolID =@ProtocolID and Type = (select  TypeID from  Type where Name ='warning')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		if LEN(@Outline) <> 0		
		BEGIN
			if (exists (select protocolID FROM PDQTwo..ProtocolData PD,  Type T where PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='outline'))
			BEGIN
				Update 	PD
				set 	PD.Data =@Outline
				FROM  PDQTwo..ProtocolData PD,  Type T
				where 	PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='outline'
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN  Tran_CreateHotfixStudyContact
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END
			END 
		END
		else
		BEGIN
			delete 	FROM  PDQTwo..ProtocolData 
			where 	ProtocolID =@ProtocolID and Type = (select  TypeID from  Type where Name ='outline')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		if LEN(@SpeciaStudyParameters) <> 0		
		BEGIN
			if (exists (select protocolID FROM PDQTwo..ProtocolData PD,  Type T where PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='special study parameters'))
			BEGIN
				Update 	PD
				set 	PD.Data =@SpeciaStudyParameters
				FROM  	PDQTwo..ProtocolData PD,  Type T
				where 	PD.ProtocolID =@ProtocolID and PD.Type = T.TypeID and  T.Name ='special study parameters'
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN  Tran_CreateHotfixStudyContact
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END
			END 
		END
		else
		BEGIN
			delete 	FROM  	PDQTwo..ProtocolData 
			where 	ProtocolID =@ProtocolID and Type = (select  TypeID from  Type where Name ='special study parameters')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		if ( EXISTS (SELECT ProtocolID FROM CancerGovStaging..HotFixProtocolStudyContact WHERE  ProtocolID = @ProtocolID))
		BEGIN
			Delete from 	PDQTwo..ProtocolStudyContact
			where 	ProtocolID =@ProtocolID
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_CreateHotfixStudyContact
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
			
			/*
			** STEP - B
			** Loop through all objects in the ProtocolStudyContact Table and update  each one in hotfix table
			** if not return a 70004 error  PDQOne..ProtocolStudyContact
			*/
			BEGIN
				DECLARE StudyContact_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
					SELECT  PersonID, OrganizationID,CountryID,StateID,Country,State,City,OrganizationName,PersonName,PhoneNumber,OrgInfo
					FROM 		HotFixProtocolStudyContact
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
					insert into 	PDQTwo..ProtocolStudyContact
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
		END
	END

	Update 	HotFixProtocolStudyContact
	set 	IsApproved=1
	where 	ProtocolID =@ProtocolID 
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN  Tran_CreateHotfixStudyContact
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 


	Update 	HotFixProtocol
	set 	IsApproved=1
	where 	ProtocolID =@ProtocolID 
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN  Tran_CreateHotfixStudyContact
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	COMMIT TRAN   Tran_CreateHotfixStudyContact

	SET NOCOUNT OFF
	RETURN 0 
END
GO
