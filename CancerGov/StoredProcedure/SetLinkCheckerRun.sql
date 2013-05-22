IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[SetLinkCheckerRun]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[SetLinkCheckerRun]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE  [dbo].[SetLinkCheckerRun]

/**************************************************************************************************
* Name		: dbo.SetLinkCheckerRun
* Purpose	: 
* Author	: 
* Date		: Sep 07, 2007
* Params    : 
* Returns	: n/a
* Usage		: 
* Changes	: none
**************************************************************************************************/
	@RunID uniqueidentifier output
AS
Begin
  --Declaration	
  --Initialization
	set nocount on;
  --Execute
			Set @RunID=newid()

			Insert Into LinkCheckerRuns(RunID
				, StatusDate)
			Values(@RunID
				, getdate()
				)
				
End
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[SetLinkCheckerRun]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
Begin
	GRANT EXECUTE on dbo.SetLinkCheckerRun TO LinkCheckUser
End
GO