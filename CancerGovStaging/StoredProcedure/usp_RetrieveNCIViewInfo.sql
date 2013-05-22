IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveNCIViewInfo]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveNCIViewInfo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**********************************************************************************

	Object's name:	usp_RetrieveNCIViewInfo
	Object's type:	store proc
	Purpose:	Retrieve NCIView
	Author:		1/15/2002	Jhe	For admin side Script
			10/25/2004	Lijia	Remove OLDURL,HTMLAddendum and add ReviewedDate, ChangeComments

**********************************************************************************/	

CREATE PROCEDURE dbo.usp_RetrieveNCIViewInfo
	(
	@ViewID	uniqueidentifier
	)
AS
BEGIN

	set arithabort ON
	
	IF @ViewID IS NULL OR NOT EXISTS (SELECT NCIViewID FROM nciview WHERE NCIViewID = @ViewID)
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	DECLARE @XhtmlDenied varchar(6)
	select @XhtmlDenied =[PropertyValue] from [CancerGovStaging].[dbo].[ViewProperty]
    where [NCIViewID] = @ViewId and [PropertyName] ='XHTMLDenied'

	IF EXISTS (select 1 FROM  NCIView  WHERE   NCIViewID  =@ViewID AND (NCITemplateID IS NULL OR len(NCITemplateID) =0))	
	BEGIN
		SELECT  N.NCIViewID, 
			N.Title,  
			N.ShortTitle, 
			N.NCITemplateID, 
			N.GroupID, 
			N.NCISectionID, 
			N.[Description],
			N.URL, 
			N.URLArguments, 
			N.MetaTitle,
			N.MetaDescription, 
			N.MetaKeyword,
			N.CreateDate, 
			N.ReleaseDate, 
			N.ExpirationDate, 
			N.Version, 
			N.Status, 
			N.IsOnProduction,  
			N.IsMultiSourced, 
			N.IsLinkExternal, 
			N.SpiderDepth, 
			N.UpdateDate, 
			N.UpdateUserID, 
			N.PostedDate, 
			N.DisplayDateMode,
			S.[Name] as 'Name', 
			G.GroupName,
			N.ReviewedDate,
			N.ChangeComments,
			dbo.udf_ViewXHTML_Valid(N.nciviewid, N'C:\\Temp\xhtml1-transitional.dtd') as 'isValidXHTML'
, @XhtmlDenied as XhtmlDenied
		FROM 	NCISection S, 
			NCIView N, 
			Groups  G
		WHERE 	N.NCISectionID = S.NCISectionID 
		and 	N.GroupID = G.GroupID
		AND 	N.NCIViewID  =@ViewID
	END
	ELSE
	BEGIN
		SELECT  N.NCIViewID, 
			N.Title,  
			N.ShortTitle, 
			N.NCITemplateID, 
			N.GroupID, 
			N.NCISectionID, 
			N.[Description],
			N.URL, 
			N.URLArguments, 
			N.MetaTitle, 
			N.MetaDescription, 
			N.MetaKeyword,
			N.CreateDate, 
			N.ReleaseDate, 
			N.ExpirationDate, 
			N.Version, 
			N.Status, 
			N.IsOnProduction,  
			N.IsMultiSourced, 
			N.IsLinkExternal, 
			N.SpiderDepth, 
			N.UpdateDate, 
			N.UpdateUserID, 
			N.PostedDate, 
			N.DisplayDateMode,
			T.[Name] as TName, 
			T.ClassName as 'TClassName', 
			S.[Name] as 'Name', 
			G.GroupName,
			N.ReviewedDate,
			N.ChangeComments,
			dbo.udf_ViewXHTML_Valid(N.nciviewid, N'C:\\Temp\xhtml1-transitional.dtd') as 'isValidXHTML'
, @XhtmlDenied as XhtmlDenied			
		FROM 	NCITemplate T, 
			NCISection S, 
			NCIView N, 
			Groups  G
		WHERE 	N.NCITemplateID = T.NCITemplateID 
		AND 	N.NCISectionID = S.NCISectionID 
		and 	N.GroupID = G.GroupID
		AND 	N.NCIViewID  =@ViewID
		END
END


GO
GRANT EXECUTE ON [dbo].[usp_RetrieveNCIViewInfo] TO [webadminuser_role]
GO
