IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveNLListitem]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveNLListitem]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* usp_deleteMacro for deleting macro. Only called by SubmitMacroForDeletionApproval
* Jay He 4/4/2003
*/

CREATE PROCEDURE [dbo].[usp_RetrieveNLListitem]
(
	@ListID		uniqueidentifier,
	@NCIViewID	uniqueidentifier
)
AS
BEGIN	

	select Title, ShortTitle, Description from NLListItem where ListID=@ListID and NCIViewID=@NCIViewID 			

		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 	
	

END
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveNLListitem] TO [webadminuser_role]
GO
