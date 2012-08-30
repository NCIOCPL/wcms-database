IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Endeca_GetNodes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Endeca_GetNodes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 05/02/2006
-- Description:	Get all nodes and module instances for endeca indexing
-- =============================================
CREATE PROCEDURE [dbo].[Endeca_GetNodes] 
@isLive bit = 0
AS
BEGIN

if @isLive =1 
	begin
						SELECT 
							n.NodeID,
							n.Title,
							ShortTitle,
							Description,
							pu.PrettyUrl as Url,
							mi.ModuleInstanceID,
							mi.ObjectID,
							o.ObjectTypeID
						FROM ProdNode n
						JOIN ProdPrettyUrl pu
						On n.NodeID = pu.NodeID
						JOIN ProdZoneInstance zi
						ON n.NodeID = zi.NodeID
						JOIN PRODModuleInstance mi
						ON zi.ZoneInstanceID = mi.ZoneInstanceID
						JOIN PRODObject o
						ON mi.ObjectID = o.ObjectID
						AND ((o.IsShared = 1 AND n.NodeID = o.OwnerID) OR (o.IsShared <> 1))
						WHERE n.NodeID not in (
							SELECT NodeID 
							FROM ProdNodeProperty pnp
							JOIN PropertyTemplate pt
							ON pnp.PropertyTemplateID = pt.PropertyTemplateID
							WHERE 
								(PropertyName = 'DoNotIndex' AND PropertyValue = '1')
								OR
								(PropertyName = 'RedirectUrl')
						)
						and isprimary  =1

	end
else
	begin	
				SELECT 
							n.NodeID,
							n.Title,
							ShortTitle,
							Description,
							pu.PrettyUrl as Url,
							mi.ModuleInstanceID,
							mi.ObjectID,
							o.ObjectTypeID
						FROM Node n
						JOIN PrettyUrl pu
						On n.NodeID = pu.NodeID
						JOIN ZoneInstance zi
						ON n.NodeID = zi.NodeID
						JOIN ModuleInstance mi
						ON zi.ZoneInstanceID = mi.ZoneInstanceID
						JOIN Object o
						ON mi.ObjectID = o.ObjectID
						AND ((o.IsShared = 1 AND n.NodeID = o.OwnerID) OR (o.IsShared <> 1))
						WHERE n.NodeID not in (
							SELECT NodeID 
							FROM NodeProperty pnp
							JOIN PropertyTemplate pt
							ON pnp.PropertyTemplateID = pt.PropertyTemplateID
							WHERE 
								(PropertyName = 'DoNotIndex' AND PropertyValue = '1')
								OR
								(PropertyName = 'RedirectUrl')
						)
						and isprimary  =1

	end




END

GO
GRANT EXECUTE ON [dbo].[Endeca_GetNodes] TO [Endeca]
GO
