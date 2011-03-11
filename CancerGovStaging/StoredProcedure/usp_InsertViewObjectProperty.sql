IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertViewObjectProperty]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertViewObjectProperty]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE dbo.usp_InsertViewObjectProperty
(
	@ObjectID		uniqueidentifier,
	@PropertyName		varchar(50),
	@PropertyValue		varchar(7800)
)

 AS

DECLARE @ViewObjectID	uniqueidentifier

SELECT @ViewObjectID = NCIViewObjectID 
FROM ViewObjects
WHERE ObjectID = @ObjectID

INSERT INTO ViewObjectProperty(NCIViewObjectID, PropertyName, PropertyValue)
VALUES(@ViewObjectID, @PropertyName, @PropertyValue)
GO
GRANT EXECUTE ON [dbo].[usp_InsertViewObjectProperty] TO [webadminuser_role]
GO
