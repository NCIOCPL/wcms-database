IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_PushHeader]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_PushHeader]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
**  This procedure will push header to production
**
**  Author: Jay He 04-19-02
**  Revision History:
**	1/21/2004 	Alex Pidlisnyy 	Fix bug that truncate header content over 8000 characters 
**
**  Return Values
**  0         Success
**  70001     The guid argument was invalid
**  70004     Failed during execution 
**  70005     Failed to create
**  70006     Failed to update
**
*/
CREATE PROCEDURE [dbo].[usp_PushHeader]
	(
	@HeaderID 		uniqueidentifier,  -- this is the guid for Header
	@UpdateUserID		varchar(50)
	)
AS
BEGIN	
	SET NOCOUNT ON

	if(  (@HeaderID IS NULL) OR (NOT EXISTS (SELECT HeaderID FROM Header WHERE HeaderID = @HeaderID)) )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	Declare @UpdateDate 	datetime

	select @UpdateDate = GETDATE()

	BEGIN  TRAN   Tran_PushHeader
	/*
	** STEP - PDQ1 -- A
	** Whether this header is on prod. If so, update. OTherwise, create
	** if not return a 70004 error
	*/
		if (exists (SELECT HeaderID from CancerGov..Header where HeaderID= @HeaderID ) )
		BEGIN
			PRINT '== Update'
			Update  Prod
			Set	[Name] = Stage.[Name],
				Type = Stage.Type,
				ContentType = Stage.ContentType,
				Data = Stage.Data,
				UpdateUserID = @UpdateUserID,
				UpdateDate = @UpdateDate
			FROM 	CancerGov..Header AS Prod,
				CancerGovStaging..Header AS Stage
			WHERE  	Prod.HeaderID = Stage.HeaderID
				AND Prod.HeaderID = @HeaderID 

			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_PushHeader
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END
		ELSE
		BEGIN
			PRINT 'INSERT'
			Insert into CancerGov..Header
				( 
				HeaderID,    
				[Name],    
				Type,    
				ContentType, 
				Data, 
				UpdateUserID, 
				UpdateDate)
			SELECT 	HeaderID, 
				[Name], 
				Type, 
				ContentType, 
				Data, 
				@UpdateUserID, 
				@UpdateDate
			FROM 	CancerGovStaging..Header
			WHERE 	HeaderID = @HeaderID 



			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_PushHeader
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		Update CancerGovStaging..Header
		Set	IsApproved = 1
		WHERE  HeaderID= @HeaderID 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_PushHeader
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

	COMMIT TRAN   Tran_PushHeader

	SET NOCOUNT OFF
	RETURN 0 
END
GO
GRANT EXECUTE ON [dbo].[usp_PushHeader] TO [webadminuser_role]
GO
