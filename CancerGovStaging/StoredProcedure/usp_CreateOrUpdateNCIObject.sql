IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_CreateOrUpdateNCIObject]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_CreateOrUpdateNCIObject]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertNewsletter
	Owner:	Jay He
	Script Date: 3/19/2003 14:43:49 pM 
******/

CREATE PROCEDURE dbo.usp_CreateOrUpdateNCIObject
(
	@NCIObjectID		UniqueIdentifier,
	@Name			VarChar(50),
	@TableName		VarChar(2000),
	@Description		VarChar(255),
	@UpdateUserID		varchar(50)						
)
AS
BEGIN						

	if (not exists (select NCIObjectID from NCIObject where NCIObjectID=@NCIObjectID))
	BEGIN
		Insert into NCIObject 
		(NCIObjectID, [Name], TableName, [Description], UpdateUserID) 
		values
		(@NCIObjectID,@Name,  @TableName, @Description, @UpdateUserID)
		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END
	ELSE
	BEGIN
		update NCIObject 
		set  	TableName	= @TableName, 
			[Description]	=@Description, 
			UpdateUserID  	=	@UpdateUserID  
		 where NCIObjectID=@NCIObjectID 
		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END

	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_CreateOrUpdateNCIObject] TO [webadminuser_role]
GO
