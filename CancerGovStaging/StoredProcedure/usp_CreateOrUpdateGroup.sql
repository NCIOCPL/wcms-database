IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_CreateOrUpdateGroup]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_CreateOrUpdateGroup]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertNewsletter
	Owner:	Jay He
	Script Date: 3/19/2003 14:43:49 pM 
******/

CREATE PROCEDURE dbo.usp_CreateOrUpdateGroup
(
	@GroupID		int,
	@GroupName  		VarChar(50),
	@GroupIDName		 VarChar(50),  
	@IsActive		bit,	
	@AdminEmail	 	VarChar(200),
	@ParentGroupID	int, 
	@TypeID		int,	
	@UpdateUserID		varchar(50)			


)
AS
BEGIN						

	if ( @GroupID =-1 and not exists (select GroupID from  Groups where GroupID = @GroupID))
	BEGIN
		Insert into Groups 
		(GroupName, GroupIDName,  IsActive, AdminEmail, ParentGroupID,TypeID, UpdateUserID) 
		values 
		(@GroupName,  @GroupIDName,  @IsActive,@AdminEmail, @ParentGroupID, @TypeID, @UpdateUserID)
		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END
	ELSE
	BEGIN
		update Groups 
		set 	GroupName=@GroupName, 
			GroupIDName= @GroupIDName, 
			IsActive=@IsActive, 
			AdminEmail=@AdminEmail, 
			ParentGroupID=@ParentGroupID, 
			TypeID=@TypeID, 
			UpdateUserID= @UpdateUserID 
		where GroupID=@GroupID

		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END

	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_CreateOrUpdateGroup] TO [webadminuser_role]
GO
