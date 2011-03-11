IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[bbListInsertCommand]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[bbListInsertCommand]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.bbListInsertCommand    Script Date: 10/5/2001 10:45:48 AM ******/
CREATE PROCEDURE dbo.bbListInsertCommand
(
	@ListID uniqueidentifier,
	@ListName varchar(50),
	@Select_ListID uniqueidentifier
)
AS
	SET NOCOUNT OFF;
INSERT INTO List(ListID, ListName) VALUES (@ListID, @ListName);
	SELECT ListID, ListName FROM List WHERE (ListID = @Select_ListID)

GO
