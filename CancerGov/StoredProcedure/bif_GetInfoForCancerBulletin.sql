IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[bif_GetInfoForCancerBulletin]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[bif_GetInfoForCancerBulletin]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/**********************************************************************************

	Object's name:	bif_GetInfoForCancerBulletin
	Object's type:	Stored procedure
	Purpose:	
	Author:		Lijia Chu 04/06/05
	Modified by:    		
	Change History: 

**********************************************************************************/

CREATE PROCEDURE dbo.bif_GetInfoForCancerBulletin 
	
AS

SELECT	
	n.ReleaseDate,
	p.PropertyValue	VolumeNumber,
	dbo.udf_GetViewObjectPrettyUrl(n.NCIViewId, v.ObjectId) AS PrettyUrl,
	d.Data
	
FROM	NCIView n
LEFT	JOIN ViewProperty p
ON	n.NCIViewID=p.NCIViewID
INNER JOIN ViewObjects v
ON	n.NCIViewID=V.NCIViewID
INNER JOIN Document d
ON	v.ObjectId=d.DocumentID
WHERE 	p.PropertyName='VolumeNumber'
AND	v.Type='DOCUMENT'
AND	n.NCIViewID IN (
		SELECT NCIViewID FROM ViewProperty 
		WHERE PropertyName='IsCancerBulletin' AND PropertyValue='TRUE'
		)
AND	n.NCIViewID NOT IN (
		SELECT NCIViewID FROM ViewProperty 
		WHERE PropertyName='RedirectURl' OR (PropertyName = 'DoNotIndexView' AND PropertyValue = 'true')
		)
and n.nciviewid not in
(select nciviewid from viewproperty
	where propertyname = 'isspanishcontent' and propertyvalue = 'YES')

ORDER BY n.NCIViewID,v.Priority
	






GO
GRANT EXECUTE ON [dbo].[bif_GetInfoForCancerBulletin] TO [websiteuser_role]
GO
