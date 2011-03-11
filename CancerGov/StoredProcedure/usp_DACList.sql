IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DACList]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DACList]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
**  This procedure is used by the data access list component to get all 
**   required data for a discrete list.  This information is needed when 
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
CREATE PROCEDURE dbo.usp_DACList

	@ListID		uniqueidentifier

AS
BEGIN
	/*
	** See if there is a more view id, if so get the url
	**  else just get the list info
	*/

	if(	
	   ((SELECT nciviewid FROM list where ListID = @ListID) is not null)
	  )	
	BEGIN

		SELECT l.ListID, 
			l.GroupID, 
			l.ListName, 
			l.ListDesc, 
			l.ParentListID, 
			l.Priority, 
			l.DescDisplay, 
			l.ReleaseDateDisplay, 
			l.ReleaseDateDisplayLoc,
			v.URL + IsNull(NullIf( '?'+IsNull(v.URLArguments,''),'?'),'') as MoreURL,
			dbo.udf_GetViewPrettyUrl(l.NCIViewId) AS MorePrettyURL,
			dbo.udf_GetClickLog(l.NCIViewId) as MoreIsClickLog
		FROM list l, nciview v with (readuncommitted)
		WHERE l.ListId = @ListId
		and l.nciviewid = v.nciviewid

	END ELSE
	BEGIN

		SELECT l.ListID, 
			l.GroupID, 
			l.ListName, 
			l.ListDesc, 
			l.ParentListID, 
			l.Priority, 
			l.DescDisplay, 
			l.ReleaseDateDisplay, 
			l.ReleaseDateDisplayLoc,
			null as MoreURL,
			null AS MorePrettyURL,
			'NO' as  MoreIsClickLog
		FROM list l with (readuncommitted)
		WHERE l.ListId = @ListId

	END
	
END
GO
