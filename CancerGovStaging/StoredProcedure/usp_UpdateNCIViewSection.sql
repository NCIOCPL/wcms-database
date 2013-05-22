IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateNCIViewSection]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateNCIViewSection]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
**  This procedure will update pretty url for document and summary
**
**  Author: Jay He 03-08-02
**  Revision History:
** 12-30-2002 Jay He 	Added new function to load usp_updateNCIViewSection
**  Return Values
**  0         Success
**  70001     The guid argument was invalid
**  70004     Failed during execution 
**  70005     Failed to create
**  70006     Failed to update
**
*/
CREATE PROCEDURE [dbo].[usp_UpdateNCIViewSection]
	(	
	@NCISectionID 		uniqueidentifier,   	-- proposed ncisectionid
	@GroupID		int,			-- proposed group id
	@NCIviewID 		uniqueidentifier,   	-- this is the guid for NCIView to be Updated
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
	  (@NCIviewID IS NULL) OR (NOT EXISTS (SELECT NCIViewID FROM nciview WHERE NCIViewID = @NCIviewID)) 
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	if(	
	  (@NCISectionID  IS NULL) OR (NOT EXISTS (SELECT NCISectionID  FROM NCISection  WHERE NCISectionID = @NCISectionID )) 
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
	DECLARE @UpdateDate 	datetime,
		@NewURL 		varchar(200)
	

	SELECT @UpdateDate = GETDATE()

	select 	@NewURL= (select URL from  NCISection where NCISectionID=@NCISectionID)
			     + (select T.URL  from nciview N, NCITemplate T where   N.NCIViewID=@NCIViewID and N.NCITemplateID = T.NCITemplateID) 
			     

	Update CancerGovStaging..NCIView
	set 	NCISectionID = @NCISectionID,
		GroupID = @GroupID,
		URL = @NewURL,
		UpdateUserID = @UpdateUserID,
		UpdateDate=@UpdateDate
	Where NCIViewID = @NCIviewID
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_UpdateNCIViewSection] TO [webadminuser_role]
GO
