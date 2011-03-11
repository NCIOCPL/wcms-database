IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveViewObjectCountByObjectID]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveViewObjectCountByObjectID]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveViewObject
   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/

CREATE PROCEDURE dbo.usp_RetrieveViewObjectCountByObjectID
	(
	@ObjectID	uniqueidentifier,
	@Type		varchar(50),
	@Case		varchar(50)
	)
AS
BEGIN
	
		/*if(	
			  (@ObjectID IS NULL) OR (NOT EXISTS (SELECT NCIViewID FROM viewobjects WHERE ObjectID	 = @ObjectID	)) 
		  )	
		BEGIN
			RAISERROR ( 70001, 16, 1)
			RETURN 70001
		END*/

		if (Len(@Type) >0)
		BEGIN 
			if (@Case ='IN')
			BEGIN
				PRINT 'inside in'
				SELECT count(*)
				FROM VIEWOBJECTS
				WHERE ObjectID =@ObjectID	
					AND Type in ( @Type)
			END
			ELSE if (@Case ='NOTIN')
			BEGIN
				SELECT count(*)
				FROM VIEWOBJECTS
				WHERE ObjectID =@ObjectID	
					AND Type not in (@Type)
			END
			ELSE if (@Case ='LIKE')
			BEGIN
				SELECT count(*)
				FROM VIEWOBJECTS
				WHERE ObjectID =@ObjectID	
					AND Type  like  '%' + @Type + '%'
			END
			ELSE if (@Case ='UNLIKE')
			BEGIN
				SELECT count(*)
				FROM VIEWOBJECTS
				WHERE ObjectID =@ObjectID	
					AND Type not like  '%' + @Type + '%'
			END
		END
		ELSE
		BEGIN
			if (@Case ='CANCERGOV')
			BEGIN
				SELECT count(*)
				FROM CancerGov..VIEWOBJECTS
				WHERE  ObjectID =@ObjectID	
			END
			ELSE
			BEGIN
				SELECT count(*)
				FROM VIEWOBJECTS
				WHERE  ObjectID =@ObjectID	
			END
		END
END
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveViewObjectCountByObjectID] TO [webadminuser_role]
GO
