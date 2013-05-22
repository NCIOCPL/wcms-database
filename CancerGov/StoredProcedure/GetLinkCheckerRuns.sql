IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetLinkCheckerRuns]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)

DROP PROCEDURE dbo.GetLinkCheckerRuns
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE  dbo.GetLinkCheckerRuns
/**************************************************************************************************
* Name		: dbo.GetLinkCheckerRuns
* Purpose	: 
* Author	: 
* Date		: Sep 07, 2007
* Params    : 
* Returns	: n/a
* Usage		: dbo.GetLinkCheckerRuns
* Changes	: none
**************************************************************************************************/
AS
Begin
  --Declaration		
  --Initialization
	set nocount on;
  --Execute

		SELECT [RunID]
				,[StatusDate]
			FROM [CancerGov].[dbo].[LinkCheckerRuns]

End
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetLinkCheckerRuns]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
Begin
	GRANT EXECUTE on dbo.GetLinkCheckerRuns TO webadminuser
End
GO
