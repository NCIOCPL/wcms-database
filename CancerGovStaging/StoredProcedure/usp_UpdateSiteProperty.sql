IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateSiteProperty]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateSiteProperty]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveViewObject
   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ****/
/*
CREATE PROCEDURE dbo.usp_RetrieveRightNav
AS
BEGIN
	
	*/

CREATE PROCEDURE dbo.usp_UpdateSiteProperty
	(
	@PropertyName		varchar(100),
	@PropertyValue		varchar(2084),
	@UpdateUserID		varchar(50)
	)
AS
BEGIN

	update siteproperties
	Set 	PropertyValue = @PropertyValue,
		UpdateUserID =@UpdateUserID
	Where PropertyName	= @PropertyName
				
	return 0
END
GO
GRANT EXECUTE ON [dbo].[usp_UpdateSiteProperty] TO [webadminuser_role]
GO
