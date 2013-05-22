IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_ResetProtocalandRefineSearchCache]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_ResetProtocalandRefineSearchCache]
GO

/**********************************************************************************

	Object's name:	usp_ResetProtocalandRefineSearchCache
	Purpose:	Reset isnew in protocol and refine Cache
	Comment:	This SP is called by scheduled job, UI does not call it.		


**********************************************************************************/
CREATE PROCEDURE dbo.usp_ResetProtocalandRefineSearchCache

AS


UPDATE	P
SET	P.IsNew=0
FROM	dbo.Protocol P inner join dbo.protocoldetail pd on p.protocolid =  pd.protocolid
WHERE	P.IsNew=1
  AND    pd.dateFirstPublished < dateadd(d,  -30, getdate())
GO
