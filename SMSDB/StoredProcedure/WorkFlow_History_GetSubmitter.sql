IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WorkFlow_History_GetSubmitter]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[WorkFlow_History_GetSubmitter]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE  PROCEDURE  [dbo].WorkFlow_History_GetSubmitter
/**************************************************************************************************
* Name		: EC_Event_GetOwner
* Purpose	: gets the ownwer id of a given event id
* Author	: SRamaiah
* Date		: 12/08/2006
* Returns	: ownerid
* Usage		: Exec WorkFlow_History_GetSubmitter 'D26A1633-81B8-42D2-82C4-00873A58692F'
* Changes	: 
**************************************************************************************************/
( 
	@ObjectID uniqueidentifier output
)
AS
BEGIN
	Declare @State varchar(255)

	Select @State= State from dbo.WorkFlowStatus where ObjectID = @ObjectID
	BEGIN TRY
		if (@State = 'Published' or @State = 'Draft' or @State = 'Modified')
		BEGIN
			Select top 1 UpdateUserID
			From dbo.WorkFlowHistory
			Where  ObjectID= @ObjectID  and TransitionName='Submit'
			and state ='Submitted'
			order by SequenceID desc
		END

	END TRY
	BEGIN CATCH 
		--Return Error Number
		print error_message()
		RETURN 11800
	END CATCH	  	  	  
END

GO
GRANT EXECUTE ON [dbo].[WorkFlow_History_GetSubmitter] TO [websiteuser_role]
GO
