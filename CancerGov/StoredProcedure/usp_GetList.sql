IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetList]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetList]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--***********************************************************************
-- Create New Object 
--************************************************************************

CREATE PROCEDURE dbo.usp_GetList 

	@ListId		uniqueidentifier

AS

SELECT *
FROM List
WHERE ListId = @ListId

GO
