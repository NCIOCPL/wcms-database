IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DACListItems]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DACListItems]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
**  This procedure is used by the data access listitems component to get all 
**   required data for each item in a discrete list.  This information is needed when 
**   rendering the list.
**
**  NOTE: 
**
**  Issues:  
**
**  Author: M.P. Brady 12-12-03
**  Revision History:
**
**  Return Values
**   Returns a row set with the selected data
**
*/
CREATE PROCEDURE dbo.usp_DACListItems

	@ListId		uniqueidentifier

AS
BEGIN

	SELECT li.Priority, 
		li.IsFeatured, 
		v.NciViewId, 
		v.Title, 
		v.ShortTitle, 
		v.URL + IsNull(NullIf( '?'+IsNull(v.URLArguments,''),'?'),'') as Url, 
		dbo.udf_GetViewPrettyUrl(v.NCIViewId) AS PrettyUrl, 
		v.Description,
		v.IsMultiSourced, 
		v.IsLinkExternal,
		CONVERT(varchar, v.ReleaseDate, 101) AS ReleaseDate,
		CONVERT(varchar, v.UpdateDate, 101) AS UpdateDate,
		CONVERT(varchar, v.PostedDate, 101) AS PostedDate,
		v.DisplayDateMode,
		dbo.udf_GetClickLog(v.NCIViewId) as IsClickLog

	FROM ListItem li, nciview v	

	WHERE li.ListId = @ListId
	and li.nciviewid = v.nciviewid
	ORDER BY li.Priority ASC, v.ShortTitle ASC

END
GO
