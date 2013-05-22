IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[SetLinkCheckerUrlStatus]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[SetLinkCheckerUrlStatus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE  dbo.SetLinkCheckerUrlStatus
( 
	@NCIViewID uniqueidentifier
	, @UrlType nvarchar(50)
	, @Status nvarchar(50)
	, @RunID uniqueidentifier
)
/**************************************************************************************************
* Name		: dbo.SetLinkCheckerUrlStatus
* Purpose	: 
* Author	: 
* Date		: Sep 07, 2007
* Params    : 
* Returns	: n/a
* Usage		: dbo.SetLinkCheckerUrlStatus
* Changes	: none
**************************************************************************************************/
AS
Begin
  --Declaration
  --Initialization
	set nocount on;
  --Execute

	Insert Into LinkCheckerStatus(NCIViewID
		, UrlType
		, Status
		, RunID)
	Values(@NCIViewID
		, @UrlType
		, @Status
		, @RunID
	)

End
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[SetLinkCheckerUrlStatus]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
Begin
	GRANT EXECUTE on dbo.SetLinkCheckerUrlStatus TO LinkCheckUser
End
GO
