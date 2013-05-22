IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetNCIChildObjects]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetNCIChildObjects]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--***********************************************************************
-- Create New Object 
--************************************************************************

CREATE PROCEDURE dbo.usp_GetNCIChildObjects

@ParentNCIObjectID	uniqueidentifier

AS

SELECT *
FROM NCIObjects
WHERE ParentNCIObjectID = @ParentNCIObjectID

GO
GRANT EXECUTE ON [dbo].[usp_GetNCIChildObjects] TO [websiteuser_role]
GO
