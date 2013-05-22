IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveViewObjectList]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveViewObjectList]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveViewObject
   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/

CREATE PROCEDURE dbo.usp_RetrieveViewObjectList
	(
	@ViewID	uniqueidentifier,
	@Type		varchar(20)
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

		SELECT L.ListID, L.ListName, L.ListDesc, V.Priority 
		FROM ViewObjects V, List L 
		WHERE L.ListID = V.ObjectID  AND V.NCIViewID=@ViewID
			AND V.Type =@Type
		ORDER BY V.Priority
/*
		if (Len(@Type) >0)
		BEGIN 
			SELECT L.ListID, L.ListName, L.ListDesc, V.Priority 
			FROM ViewObjects V, List L 
			WHERE L.ListID = V.ObjectID  AND V.NCIViewID=@ViewID
				AND V.Type =@Type
			ORDER BY V.Priority
		END
		ELSE
		BEGIN
			SELECT NCIViewObjectID, ObjectID
			FROM VIEWOBJECTS
			WHERE NCIViewID =@ViewID
		END
*/
END
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveViewObjectList] TO [webadminuser_role]
GO
