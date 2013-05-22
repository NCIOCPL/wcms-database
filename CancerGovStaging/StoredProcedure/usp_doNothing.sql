IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_doNothing]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_doNothing]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
**  This procedure is used only to return a success to mark time/
**  approval with in the concept of step with in a task
**
**  NOTE: 
**
**  Issues:  
**
**  Author: M.P. Brady 11-01-01
**  Revision History:
**
**
**  Return Values
**  0         Success
**
*/
CREATE PROCEDURE [dbo].[usp_doNothing] 
	(
	@UpdateUserID varchar(50) = 'system'    -- Not used, but the system will always pass this in as the 
	                                        -- if used as a step command
	)
AS
BEGIN	

	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_doNothing] TO [webadminuser_role]
GO
