IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetNCIObjectProperties]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetNCIObjectProperties]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--***********************************************************************
-- Create New Object 
--************************************************************************

CREATE PROCEDURE dbo.usp_GetNCIObjectProperties

@ObjectInstanceID	uniqueidentifier

AS

SELECT *
FROM NCIObjectProperty
WHERE ObjectInstanceID = @ObjectInstanceID

GO
GRANT EXECUTE ON [dbo].[usp_GetNCIObjectProperties] TO [websiteuser_role]
GO
