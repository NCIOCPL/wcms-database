IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveNCIObjectPriority]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveNCIObjectPriority]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--***********************************************************************
-- Create New Object 
--************************************************************************
/****** Object:  Stored Procedure dbo.usp_RetrieveViewObject
   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ****/
/*
CREATE PROCEDURE dbo.usp_RetrieveRightNav
AS
BEGIN
	
	*/

CREATE PROCEDURE dbo.usp_RetrieveNCIObjectPriority
	(
	@ParentNCIObjectID	uniqueidentifier,
	@Type 		varchar(30)
	)
AS
BEGIN

	if(	
		  @ParentNCIObjectID IS NULL
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	if (@Type ='INFOBOX')
	BEGIN
		SELECT ObjectInstanceID, NCIObjectID, Priority
		FROM NCIObjects
		WHERE ParentNCIObjectID =@ParentNCIObjectID AND (ObjectType = 'list' OR ObjectType = 'navdoc' OR ObjectType Like '%image')
		ORDER by Priority 
	END
			
		
END

GO
GRANT EXECUTE ON [dbo].[usp_RetrieveNCIObjectPriority] TO [webadminuser_role]
GO
