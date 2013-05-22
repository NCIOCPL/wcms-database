IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveNCIObject]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveNCIObject]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--***********************************************************************
-- Create New Object 
--************************************************************************



CREATE PROCEDURE dbo.usp_RetrieveNCIObject
	(
	@NCIObjectID uniqueidentifier
	)
AS
BEGIN

	SELECT *
	FROM 	NCIObjects
	WHERE ParentNCIObjectID = @NCIObjectID
END

GO
