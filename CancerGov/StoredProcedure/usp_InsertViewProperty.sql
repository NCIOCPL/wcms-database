IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertViewProperty]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertViewProperty]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE dbo.usp_InsertViewProperty
(
	@NCIViewID		uniqueidentifier,
	@PropertyName		varchar(50),
	@PropertyValue		varchar(7800)
)

 AS

INSERT INTO ViewProperty(NCIViewID, PropertyName, PropertyValue)
VALUES(@NCIViewID, @PropertyName, @PropertyValue)
GO
