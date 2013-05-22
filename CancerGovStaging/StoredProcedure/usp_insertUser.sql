IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_insertUser]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_insertUser]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* usp_deleteMacro for deleting macro. Only called by SubmitMacroForDeletionApproval
* Jay He 4/4/2003
*/

CREATE PROCEDURE [dbo].[usp_insertUser]
(
	@LoginName 	varchar(40),
	@Email		varchar(200),
	@Password 	varchar(100)
)
AS
BEGIN	
	SET NOCOUNT ON;


	INSERT INTO NCIUsers 
	(LoginName, Email, [Password]) 
	VALUES 
	(@LoginName, @Email, @Password)				

		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 	
	

	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_insertUser] TO [webadminuser_role]
GO
