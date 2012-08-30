IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Object_SearchSharedObjects]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Object_SearchSharedObjects]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


Create  PROCEDURE [dbo].Core_Object_SearchSharedObjects
	@Title varchar(255)=null,
	@Type int
AS
BEGIN

	select ObjectID, O.Title, ObjectTypeID
	From dbo.Object O
	where IsShared= 1 and (@Title is null or O.Title like '%' + @Title + '%')


END



GO
GRANT EXECUTE ON [dbo].[Core_Object_SearchSharedObjects] TO [websiteuser_role]
GO
