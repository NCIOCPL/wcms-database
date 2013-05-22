IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[bbListDeleteCommand]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[bbListDeleteCommand]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.bbListDeleteCommand    Script Date: 10/5/2001 10:45:48 AM ******/
CREATE PROCEDURE dbo.bbListDeleteCommand
(
	@ListID uniqueidentifier,
	@ListName varchar(50)
)
AS
	SET NOCOUNT OFF;
DELETE FROM List WHERE (ListID = @ListID) AND (ListName = @ListName)

GO
