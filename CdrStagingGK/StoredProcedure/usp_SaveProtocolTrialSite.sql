IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveProtocolTrialSite]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveProtocolTrialSite]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*	NCI - National Cancer Institute
*	
*	Purpose:	
*
*	Objects Used:
*
*	Change History:

*	To Do List:
*
*/
CREATE PROCEDURE dbo.usp_SaveProtocolTrialSite
	(
		@ProtocolContactInfoID int output, 
		@ProtocolID int, 
		@OrganizationID int, 
		@PersonID int, 
		@OrganizationName varchar(500), 
		@PersonGivenName varchar(255), 
		@PersonSurName varchar(255), 
		@OrganizationRole varchar(100), 
		@City varchar(100), 
		@StateID int, 
		@Country varchar(255), 
		@ZIP varchar(5), 
		@UpdateUserID varchar(50), 
		@PersonProfessionalSuffix varchar(255), 
		@statefullname varchar(100), 
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	
	declare @shortName varchar(50)
	
	select @shortName = shortname from dbo.politicalSubunit where politicalsubunitid =  @StateID


	insert into dbo.ProtocolTrialSite
	(	
		ProtocolID,
		OrganizationID,
		PersonID,
		OrganizationName,
		PersonGivenName,
		PersonSurName,
		OrganizationRole,
		City,
		State,
		Country,
		ZIP,
		UpdateUserID,
		PersonProfessionalSuffix,
		statefullname,
		updateDate
	)
	VALUES (
			@ProtocolID,
			@OrganizationID,
			@PersonID,
			@OrganizationName,
			@PersonGivenName,
			@PersonSurName,
			@OrganizationRole,
			@City,
			isnull(@shortName, @statefullname),
			@Country,
			@ZIP,
			@UpdateUserID,
			@PersonProfessionalSuffix,
			@statefullname,
			@updateDate
		)
	
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @ProtocolID,'ProtocolTrialSite')
		RETURN 69990
	END 

	set @ProtocolContactInfoID = scope_identity()

	if @isDebug =1  PRINT  '  ***       - dbo.ProtocolTrialSite table Saved for ID: '+ convert(varchar(50), @ProtocolID)
		

	
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveProtocolTrialSite] TO [Gatekeeper_role]
GO
