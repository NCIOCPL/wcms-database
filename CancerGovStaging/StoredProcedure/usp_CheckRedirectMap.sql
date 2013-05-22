IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_CheckRedirectMap]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_CheckRedirectMap]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
**  This procedure will create pretty url map in redirectMap table
**
**  Author: Jay He 03-19-02
**  Revision History:
**  04-11-2002	Jay He		AFter discussing with chen, we think it's better for us to put only real url in current url column. This will make life easier.
**
**  Return Values
**  0         Success
**  70001     The  argument was invalid
**  70004     Failed during execution 
**  70005     Failed to create
**  70006     Failed to update
**  70007     Failed to delete
*/
CREATE PROCEDURE [dbo].[usp_CheckRedirectMap]
	(
	@OldURL 	varchar(512),	 -- old pretty URL needed to updated in redirectMap table
	@CurrentURL 	varchar(512),      -- new pretty url 
	@PhysicalPath	varchar(512), 	-- physical path
	@Source	varchar(20), 	-- indicate source
	@UpdateRedirectOrNot	bit	-- indicate whether update redirect table
	)
AS
BEGIN	
	SET NOCOUNT ON

	Declare @count int 

	--BEGIN TRAN  Tran_CheckRedirectMap
	/*
	** default function no matter what value UpdateRedirectOrNot is
	*/	
	IF @OldURL = @CurrentURL 
	BEGIN
		--ROLLBACK TRAN Tran_CheckRedirectMap
		RAISERROR ( 70001, 16, 1)
		RETURN
	END
	
	IF @UpdateRedirectOrNot=1
	BEGIN
			
		-- delete all records in redirecmap table where oldURL = current URL to gurantee only one unique current URL
		PRINT '-- Delete from redirectMap'
		delete from CancerGov..redirectMap where oldURL = @CurrentURL
		IF (@@ERROR <> 0)
			BEGIN
				--ROLLBACK TRAN Tran_CheckRedirectMap
				RAISERROR ( 70007, 16, 1)
				RETURN
			END 	

		-- Insert a new map no matter the old url exists in db as currenturl or not
		PRINT '-- Insert a new map no matter the old url exists in db as currenturl or not'	+ Convert(varchar(200), @OldURL)	
		Insert into CancerGov..redirectMap (oldURL, currentURL, source)
		Values  (@OldURL, @PhysicalPath, @Source)
		IF (@@ERROR <> 0)
			BEGIN
				--ROLLBACK TRAN Tran_CheckRedirectMap
				RAISERROR ( 70005, 16, 1)
				RETURN
			END 	
	END
	ELSE
	IF  @UpdateRedirectOrNot=0
	BEGIN
		-- Delete all records in redirecmap table where oldURL = current URL to gurantee only one unique current URL
		delete from CancerGov..redirectMap where oldURL = @CurrentURL
		IF (@@ERROR <> 0)
			BEGIN
				--ROLLBACK TRAN Tran_CheckRedirectMap
				RAISERROR ( 70007, 16, 1)
				RETURN 
			END 	

	END  

	--COMMIT TRAN   Tran_CheckRedirectMap

	SET NOCOUNT OFF
	RETURN 0 
END
GO
GRANT EXECUTE ON [dbo].[usp_CheckRedirectMap] TO [webadminuser_role]
GO
