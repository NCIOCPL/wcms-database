IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveListitemCount]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveListitemCount]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* usp_deleteMacro for deleting macro. Only called by SubmitMacroForDeletionApproval
* Jay He 4/4/2003
*/

CREATE PROCEDURE [dbo].[usp_RetrieveListitemCount]
(
	@ListID		uniqueidentifier,
	@NCIViewID	uniqueidentifier,
	@Type		varchar(20)
)
AS
BEGIN	
	if (@Type ='LIST')
	BEGIN
		select count(*) from listitem where ListID =@ListID and NCIViewID=@NCIViewID 	
	END
	ELSE
	BEGIN
		select count(*)  from NLListItem where ListID=@ListID and NCIViewID=@NCIViewID 			
	END

END
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveListitemCount] TO [webadminuser_role]
GO
