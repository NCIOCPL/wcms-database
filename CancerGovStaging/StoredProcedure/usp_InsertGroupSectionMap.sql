IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertGroupSectionMap]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertGroupSectionMap]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertLink  
	Purpose: This script can be used for  inserting viewobjects.	Script Date: 4/30/2002 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_InsertGroupSectionMap
(
	@GroupID		int,
	@SectionID		uniqueidentifier,
	@UpdateUserID		varchar(40)
)
AS
BEGIN
	SET NOCOUNT ON;
		
	Declare @Count int
	
	Select @Count = count(*) from SectionGroupMap 
	where GroupId =@GroupID and SectionID =@SectionID

	if (@Count =0)
	BEGIN
		INSERT INTO SectionGroupMap 
		(SectionID, GroupID, updatedate, updateuserID) 
		VALUES
		(@SectionID, @GroupID, getdate(), @UpdateUserID)					
		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END
	END

	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_InsertGroupSectionMap] TO [webadminuser_role]
GO
