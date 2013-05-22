IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].usp_GetDrugInfoSummaries') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].usp_GetDrugInfoSummaries
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_GetDrugInfoSummaries  
* Owner:Jhe 
* Purpose: For admin side Script Date: 12/28/2009  ******/


CREATE PROCEDURE [dbo].usp_GetDrugInfoSummaries
AS
BEGIN	

		SELECT NCIViewID
		FROM NCIView 
		where  ncisectionid = 'F2901263-4A99-44A8-A1DA-92B16E173E86' 
	
END

GO
GRANT EXECUTE ON [dbo].usp_GetDrugInfoSummaries TO [webadminuser_role]
GO
