IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[bbListUpdateCommand]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[bbListUpdateCommand]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.bbListUpdateCommand    Script Date: 10/5/2001 10:45:48 AM ******/
CREATE PROCEDURE dbo.bbListUpdateCommand
(
	@ListID uniqueidentifier,
	@ListName varchar(50),
	@Original_ListID uniqueidentifier,
	@Original_ListName varchar(50),
	@Select_ListID uniqueidentifier
)
AS
	SET NOCOUNT OFF;
UPDATE List SET ListID = @ListID, ListName = @ListName WHERE (ListID = @Original_ListID) AND (ListName = @Original_ListName);
	SELECT ListID, ListName FROM List WHERE (ListID = @Select_ListID)

GO
