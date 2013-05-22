IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetLinkCheckerViews]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)

DROP PROCEDURE dbo.GetLinkCheckerViews
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE  dbo.GetLinkCheckerViews
/**************************************************************************************************
* Name		: dbo.GetLinkCheckerViews
* Purpose	: 
* Author	: 
* Date		: Dec 18, 2008
* Params    : 
* Returns	: n/a
* Usage		: dbo.GetLinkCheckerViews
* Changes	: none
**************************************************************************************************/
AS
Begin
  --Declaration		
  --Initialization
	set nocount on;
  --Execute

		select nv.NCIViewID, nv.Title,
							(case
								when pu.CurrentUrl is null then nv.URL
								else pu.CurrentUrl
							 end) as URL,
								URLType = 'PDF'   
		from NCIView nv
		left outer join PrettyUrl pu
		on pu.NCIViewID = nv.NCIViewID and pu.IsPrimary = 1
		where nv.NCITemplateID = '05BFA291-F1AE-42F9-ACD2-CDC9E2F892F0'
		union
		select NCIViewID, Title, 
							(URL + case
									when URLArguments is null then ''
									when URLArguments = '' then ''
									else ('?' + URLArguments)
								   end
							 ) as URL,
							URLType = 'AddALink'
		from NCIView
		where NCITemplateID is null
		UNION
		select 
			NCIViewID,
			Title,
			(Select PropertyValue FROM ViewProperty where NCIViewID = nv.NCIViewID and PropertyName='RedirectURL' and propertyValue is not null and propertyvalue <> '') as URL,
			'RedirectUrl' as URLType
		FROM NCIView nv
		WHERE NCIViewID in (SELECT NCIViewID from ViewProperty where PropertyName='RedirectURL' and propertyValue is not null and propertyvalue <> '') AND NCITemplateID <> '05BFA291-F1AE-42F9-ACD2-CDC9E2F892F0'
	

End
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetLinkCheckerViews]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
Begin
	GRANT EXECUTE on dbo.GetLinkCheckerViews TO LinkCheckUser
End
GO
