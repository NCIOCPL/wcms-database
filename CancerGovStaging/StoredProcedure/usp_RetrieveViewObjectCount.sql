IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveViewObjectCount]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveViewObjectCount]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveViewObject
   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/

CREATE PROCEDURE dbo.usp_RetrieveViewObjectCount
	(
	@ViewID	uniqueidentifier,
	@Type		varchar(50),
	@Case		varchar(50)
	)
AS
BEGIN
	
		if(	
			  (@ViewID IS NULL) OR (NOT EXISTS (SELECT NCIViewID FROM nciview WHERE NCIViewID = @ViewID)) 
		  )	
		BEGIN
			RAISERROR ( 70001, 16, 1)
			RETURN 70001
		END

		if (Len(@Type) >0)
		BEGIN 
			if (@Case ='IN')
			BEGIN
				SELECT count(*)
				FROM VIEWOBJECTS
				WHERE NCIViewID =@ViewID
					AND Type in ( @Type)
			END
			ELSE if (@Case ='NOTIN')
			BEGIN
				SELECT count(*)
				FROM VIEWOBJECTS
				WHERE NCIViewID =@ViewID
					AND Type not in ( @Type)
			END
			ELSE if (@Case ='LIKE')
			BEGIN
				SELECT count(*)
				FROM VIEWOBJECTS
				WHERE NCIViewID =@ViewID
					AND Type like '%' + @Type +'%'
			END
			ELSE if (@Case ='UNLIKE')
			BEGIN
				SELECT count(*)
				FROM VIEWOBJECTS
				WHERE NCIViewID =@ViewID
					AND Type not  like '%' + @Type +'%'
			END
		
		END
		ELSE
		BEGIN
			SELECT count(*)
			FROM VIEWOBJECTS
			WHERE NCIViewID = @ViewID
		END
END
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveViewObjectCount] TO [webadminuser_role]
GO
