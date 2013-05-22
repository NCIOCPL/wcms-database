IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_CreateOrUpdateSite]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_CreateOrUpdateSite]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--***********************************************************************
-- Create New Object 
--************************************************************************


CREATE PROCEDURE dbo.usp_CreateOrUpdateSite
(
	@NCISiteID		UniqueIdentifier,
	@Name			VarChar(50),
	@Description		VarChar(255),
	@UpdateUserID		varchar(50)						
)
AS
BEGIN						

	if (not exists (select NCISiteID from NCISite where NCISiteID =@NCISiteID ))
	BEGIN
		Insert into NCISite 
		(NCISiteID , [Name],  [Description],  UpdateUserID) 
		values 
		(@NCISiteID , @Name,  @Description,  @UpdateUserID)
		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END
	ELSE
	BEGIN
		update NCISite
		set 	[Name]	=@Name, 
			[Description]	=@Description, 
			UpdateDate	= 	getdate(),  
			UpdateUserID  	=	@UpdateUserID  
		 where NCISiteID =@NCISiteID 
		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END

	RETURN 0 

END

GO
GRANT EXECUTE ON [dbo].[usp_CreateOrUpdateSite] TO [webadminuser_role]
GO
