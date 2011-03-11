IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveViewObjectByObjectID]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveViewObjectByObjectID]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveViewObject
   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/

CREATE PROCEDURE dbo.usp_RetrieveViewObjectByObjectID
	(
	@ObjectID	uniqueidentifier,
	@Type		varchar(50),
	@Case		varchar(50)
	)
AS
BEGIN
	
	if(	
		  (@ObjectID IS NULL) OR (NOT EXISTS (SELECT NCIViewID FROM viewobjects WHERE ObjectID = @ObjectID)) 
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END


	if (Len(@Type) >0)
	BEGIN 
			if (@Case ='IN')
			BEGIN
				SELECT NCIViewObjectID, NCIViewID, Priority, Type
				FROM VIEWOBJECTS
				WHERE ObjectID = @ObjectID
					AND Type in (@Type)
				Order By Priority
			END
			if (@Case ='NOTIN')
			BEGIN
				SELECT NCIViewObjectID, NCIViewID, Priority, Type
				FROM VIEWOBJECTS
				WHERE ObjectID = @ObjectID
					AND Type not in (@Type)
				Order By Priority
			END
			ELSE 	if (@Case ='LIKE')
			BEGIN
				SELECT NCIViewObjectID, NCIViewID, Priority, Type
				FROM VIEWOBJECTS
				WHERE ObjectID = @ObjectID
					AND Type LIKE '%' + @Type +'%'
				Order By Priority
			END
			ELSE if (@Case ='UNLIKE')
			BEGIN
				SELECT NCIViewObjectID, NCIViewID, Priority, Type
				FROM VIEWOBJECTS
				WHERE ObjectID = @ObjectID
					AND Type  not LIKE '%' + @Type +'%'
				Order By Priority
			END
	END
	ELSE
	BEGIN
			SELECT NCIViewObjectID, NCIViewID, Priority, Type
			FROM VIEWOBJECTS
			WHERE ObjectID = @ObjectID
			Order By Priority
	END
END
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveViewObjectByObjectID] TO [webadminuser_role]
GO
