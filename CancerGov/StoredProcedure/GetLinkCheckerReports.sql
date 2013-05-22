IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetLinkCheckerReports]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)

DROP PROCEDURE dbo.GetLinkCheckerReports
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE  dbo.GetLinkCheckerReports
( 
	@RunID uniqueidentifier
)
/**************************************************************************************************
* Name		: dbo.GetLinkCheckerReports
* Purpose	: 
* Author	: 
* Date		: Sep 07, 2007
* Params    : 
* Returns	: n/a
* Usage		: dbo.GetLinkCheckerReports 'runID'
* Changes	: none
**************************************************************************************************/
AS
Begin
  --Declaration		
  --Initialization
	set nocount on;
  --Execute
		--Table 0 has the number of urls tested
		SELECT lcr.RunID, (SELECT count(*) FROM LinkCheckerStatus WHERE RunID = @RunID) as LinksChecked
		FROM LinkCheckerRuns lcr
		WHERE lcr.RunID = @RunID

		--Table 1 has the statuses
		Select nv.NCIViewID
				, Title
				,(CASE
						WHEN URL like '/'+'%' THEN 'http://www.cancer.gov'+URL+CASE
																				WHEN URLArguments is null THEN ''
																				WHEN URLArguments = '' THEN ''
																				ELSE ('?' + URLArguments)
																			END
						ELSE 
							URL + CASE
							WHEN URLArguments is null THEN ''
							WHEN URLArguments = '' THEN ''
							ELSE ('?' + URLArguments)
							END
					END
					) as URL
				, UrlType
				, lcs.Status
		From LinkCheckerStatus lcs
		JOIN NCIView nv
		ON lcs.NCIViewID = nv.NCIViewID
		WHERE lcs.status <> 'OK' 
		AND UrlType='AddALink'
		AND RunID = @RunID
		UNION
		Select nv.NCIViewID, Title, 'http://www.cancer.gov'+CurrentUrl as URL, UrlType, lcs.Status
		From LinkCheckerStatus lcs
		JOIN NCIView nv
		ON lcs.NCIViewID = nv.NCIViewID
		JOIN PrettyURL pu
		ON pu.NCIViewID = nv.NCIViewID
		AND pu.IsPrimary = 1
		WHERE lcs.status <> 'OK' 
		AND UrlType='pdf'
		AND RunID = @RunID
		UNION
		select 
			lcs.NCIViewID,
			Title,
			(CASE
				WHEN (Select PropertyValue FROM ViewProperty where NCIViewID = nv.NCIViewID and PropertyName='RedirectURL' and propertyValue is not null and propertyvalue <> '') LIKE '/'+'%' THEN 'http://www.cancer.gov' + (Select PropertyValue FROM ViewProperty where NCIViewID = nv.NCIViewID and PropertyName='RedirectURL' and propertyValue is not null and propertyvalue <> '')
				ELSE (Select PropertyValue FROM ViewProperty where NCIViewID = nv.NCIViewID and PropertyName='RedirectURL' and propertyValue is not null and propertyvalue <> '')
			END) as URL,
			URLType,
			lcs.Status
		FROM LinkCheckerStatus lcs
		JOIN NCIView nv
		ON lcs.NCIViewID = nv.NCIViewID
		WHERE lcs.Status <> 'OK'
		AND UrlType='RedirectUrl'
		AND RunID = @RunID
		AND (Select PropertyValue FROM ViewProperty where NCIViewID = nv.NCIViewID and PropertyName='RedirectURL' and propertyValue is not null and propertyvalue <> '') is not null
		UNION
		select
			lcs.NCIViewID,
			Title,
			URL,
			URLType,
			lcs.Status
		FROM LinkCheckerStatus lcs
		JOIN NCIView nv
		ON lcs.NCIViewID = nv.NCIViewID
		Where lcs.Status = 'MissingUrl'
		AND RunID = @RunID

		--Table 2 has the orphaned links
		SELECT v.NCIViewID
				, v.Title
				, (CASE
						WHEN URL like '/'+'%' THEN 'http://www.cancer.gov'+URL+CASE
																					WHEN URLArguments is null THEN ''
																					WHEN URLArguments = '' THEN ''
																					ELSE ('?' + URLArguments)
																				END
						ELSE 
							URL + CASE
										WHEN URLArguments is null THEN ''
										WHEN URLArguments = '' THEN ''
										ELSE ('?' + URLArguments)
									END
					END
				) as URL
		FROM (
			  SELECT NCIViewID, 
			  CNT = (select count(*) FROM CancerGovStaging.dbo.ListItem
			  WHERE NCIViewID = v.NCIViewID) +
			  (select count(*) FROM CancerGov.dbo.ListItem
			  WHERE NCIViewID = v.NCIViewID)
			  FROM NCIView v
			  WHERE NCITemplateID is null
		) as t
		JOIN CancerGovStaging.dbo.NCIView v 
		ON t.NCIViewID = v.NCIViewID
		WHERE CNT = 0

End
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetLinkCheckerReports]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
Begin
	GRANT EXECUTE on dbo.GetLinkCheckerReports TO webadminuser
End
GO
