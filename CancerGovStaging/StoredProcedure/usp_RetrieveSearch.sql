IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveSearch]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveSearch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--***********************************************************************
-- Create New Object 
--************************************************************************


CREATE PROCEDURE [dbo].[usp_RetrieveSearch]
(
	@DocumentID		uniqueidentifier,
	@NCIViewID	uniqueidentifier
)
AS
BEGIN	

	SELECT D.data, D.Title, D.ShortTitle FROM Document D, ViewObjects V 
	WHERE D.DocumentID = V.ObjectID and D.DocumentID =@DocumentID 
		and (V.Type ='SEARCH'  or V.Type ='VIRSEARCH') and  V.NCIViewID =@NCIViewID 			

		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 	
	

END

GO
GRANT EXECUTE ON [dbo].[usp_RetrieveSearch] TO [webadminuser_role]
GO
