IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateNCIViewStatus]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateNCIViewStatus]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/**********************************************************************************

	Object's name:	usp_UpdateNCIViewStatus
	Object's type:	Stored procedure
	Purpose:	Update View's status
	
	Change History:
	10/19/2004	Lijia Chu	

**********************************************************************************/
					
					
CREATE PROCEDURE dbo.usp_UpdateNCIViewStatus
(
	@NCIViewID	UniqueIdentifier,
	@Status		VARCHAR(10)
)
AS
	SET NOCOUNT OFF;


	Update NCIView
	set 	Status =@Status,
		UpdateDate= getdate()
	where 	NCIViewID = @NCIViewID
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 


	RETURN 0

GO
GRANT EXECUTE ON [dbo].[usp_UpdateNCIViewStatus] TO [gatekeeper_role]
GO
GRANT EXECUTE ON [dbo].[usp_UpdateNCIViewStatus] TO [websiteuser_role]
GO
