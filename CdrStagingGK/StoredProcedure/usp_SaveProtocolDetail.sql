IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveProtocolDetail]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveProtocolDetail]
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
CREATE PROCEDURE dbo.usp_SaveProtocolDetail
	(
		@protocolid int, 
		@HealthProfessionalTitle nvarchar(1000), 
		@PatientTitle nvarchar(1000), 
		@LowAge tinyint, 
		@HighAge tinyint, 
		@AgeRange varchar(500), 
		@IsPatientVersionExists bit, 
		--@PrimaryProtocolID varchar(50), 
		@isCTprotocol bit, 
	    @CurrentStatus varchar(50), 
		@DateFirstPublished datetime, 
		@DateLastModified datetime,
		@PrimaryPrettyUrlID varchar(50),
		@updateUserID varchar(50),
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	
	declare @PrimaryAlternateID varchar(50)
	select @PrimaryAlternateID =idstring from dbo.protocolAlternateID where protocolid  = @protocolid and IDtypeID  = 1

	insert into dbo.ProtocolDetail
	(	protocolid,
		HealthProfessionalTitle,
		PatientTitle,
		LowAge,
		HighAge,
		AgeRange,
		IsPatientVersionExists,
		PrimaryProtocolID,
		isCTprotocol,
		DateFirstPublished,
		DateLastModified,
		CurrentStatus,
		AlternateProtocolIDs,
		Phase,
		typeofTrial,
		sponsorofTrial,
		PrimaryPrettyUrlID,
		updateUserid,
		updateDate
	)
	VALUES (@protocolid,
		@HealthProfessionalTitle,
		@PatientTitle,
		@LowAge,
		@HighAge,
		@AgeRange,
		@IsPatientVersionExists,
		@PrimaryAlternateID,
		@isCTprotocol,
		@DateFirstPublished,
		@DateLastModified,
		@CurrentStatus,
		dbo.udf_GetProtocolAlternateIDs(@protocolid),
		dbo.udf_getProtocolPhases(@protocolid),
		dbo.udf_getProtocolStudycategory(@protocolid),
		dbo.udf_getProtocolSponsors(@protocolid),
		@PrimaryPrettyUrlID,
		@updateUserid,
		@updateDate
		)
	
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @ProtocolID,'ProtocolDetail')
		RETURN 69990
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.ProtocolDetail table Saved for ID: '+ convert(varchar(50), @ProtocolID)
		

	if @isDebug =1  PRINT  '  ***       - dbo.ProtocolDetail table Saved for ID: '+ convert(varchar(50), @ProtocolID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveProtocolDetail] TO [Gatekeeper_role]
GO
