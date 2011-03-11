IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveBenchmark]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveBenchmark]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveNCIView   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/

CREATE PROCEDURE dbo.usp_RetrieveBenchmark
	(
	@ViewID	uniqueidentifier
	)
AS
BEGIN
	(SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=A.Title 
	FROM VIEWOBJECTS VO, ExternalObject A
	WHERE VO.NCIViewID =@ViewID
		 AND VO.Type in ('audio', 'animation', 'photo') and A.ExternalObjectID = VO.ObjectID
	 )
	Union 
	(SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=D.ShortTitle 
	FROM VIEWOBJECTS VO, Document D 
	WHERE VO.NCIViewID =@ViewID 
		AND VO.Type = 'document' and D.DocumentID = VO.ObjectID 
	)
	order by VO.Priority
END
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveBenchmark] TO [webadminuser_role]
GO
