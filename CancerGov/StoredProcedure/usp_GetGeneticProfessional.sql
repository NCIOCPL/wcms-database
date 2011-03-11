IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetGeneticProfessional]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetGeneticProfessional]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_GetGeneticProfessional]
	(
	@GenProfID int
	)
AS
BEGIN
	
	
	SET NOCOUNT ON 
	CREATE TABLE #AreasOfSpecialization(
		Syndrome varchar(60), 
		CancerType varchar(500)
	)

	SELECT [ID] AS PersonID,
		FirstName + ' ' + LastName + ' ' + ISNULL(Suffix, '') AS FullName,
		Degree,
		Note 
	FROM 	GeneticsProfessional
	WHERE 	[ID] = @GenProfID 
	
	--Practice Locations
	SELECT 	ISNULL(InstitutionName,'') + '<br>' +
		ISNULL(AddressLine1,'') + '<br>' +
		ISNULL(AddressLine2,'') + '<br>' +
		ISNULL(AddressLine3 + '<br>','') +
		ISNULL(AddressLine4 + '<br>','') + 
		ISNULL( NULLIF( LTRIM(RTRIM( ISNULL(Country,'') )), 'United States') + '<br>', '') +
		ISNULL( 'Ph: ' + Phone  + '<br>','') +
		ISNULL('E-mail: <a href="mailto:' + LTRIM(RTRIM(eMail)) + '">' + LTRIM(RTRIM(eMail)) + '</a><br>' ,'') AS PracticeLocation
	FROM 	GenProfPracticeLocations
	WHERE 	GenProfID  = @GenProfID 
	
	--Profession
	SELECT 	[Name] AS Profession
	FROM 	GenProfType
	WHERE 	GenProfID  = @GenProfID 
	
	--Medical/Genetics Specialties
	SELECT 	[Name] AS Specialty, BoardCertified       
	FROM 	GenProfSpecialty
	WHERE 	GenProfID  = @GenProfID 
	
	--Member of a Team That Provides These Services
	SELECT 	Service 
	FROM 	GenProfTeamServices
	WHERE 	GenProfID  = @GenProfID 
	
	--Areas of Specialization
	DECLARE @NewSyndrome  varchar(255),
		@OldSyndrome  varchar(255),
		@CancerType varchar(255)
	
	DECLARE AreasOfSpecialization_Cursor CURSOR 
	FORWARD_ONLY FOR
	SELECT 	Syndrome, LTRIM(RTRIM(CancerSite)) AS CancerType
	FROM 	GenProfAreasOfSpecialization
	WHERE 	GenProfID  = @GenProfID 
	
	OPEN AreasOfSpecialization_Cursor 
	
	FETCH NEXT FROM AreasOfSpecialization_Cursor 
	INTO @NewSyndrome, @CancerType 
	SELECT @OldSyndrome = ''
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @OldSyndrome <> @NewSyndrome
		BEGIN
			INSERT INTO #AreasOfSpecialization(Syndrome, CancerType)
			VALUES (@NewSyndrome, @CancerType )
		END 
		ELSE BEGIN
			UPDATE 	#AreasOfSpecialization
			SET 	CancerType = CancerType + ', ' + @CancerType 
			WHERE 	Syndrome = @NewSyndrome  
		END 
		SELECT @OldSyndrome = @NewSyndrome  
		
		FETCH NEXT FROM AreasOfSpecialization_Cursor 
		INTO @NewSyndrome, @CancerType 
	END
	
	CLOSE AreasOfSpecialization_Cursor 
	DEALLOCATE AreasOfSpecialization_Cursor 

	SELECT 	Syndrome, 
		CancerType 		
	FROM 	#AreasOfSpecialization

	--Professional Organizations
	SELECT 	InstitutionName   
	FROM 	GenProfMembership
	WHERE 	GenProfID  = @GenProfID 

	DROP TABLE #AreasOfSpecialization
	SET NOCOUNT OFF 
	

END
GO
