IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateLink]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateLink]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_UpdateLink
	Owner:	Jay He
	Script Date: 3/17/2003 14:43:49 pM 
******/

CREATE PROCEDURE dbo.usp_UpdateLink
(
	@Title				varChar(255),
	@URL				varChar(1000),
	@LinkID			UniqueIdentifier,
	@InternalOrExternal		bit,												 
	@UpdateUserID  		VarChar(50)
)
AS
BEGIN

	UPDATE Link
	set 	Title=@Title,
		URL=@URL,
		InternalOrExternal=@InternalOrExternal,
		UpdateUserID= @UpdateUserID
	where LinkID = @LinkID
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	RETURN 0 

END
GO
