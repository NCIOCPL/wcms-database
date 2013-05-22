IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[bbListSelectCommand]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[bbListSelectCommand]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.bbListSelectCommand    Script Date: 10/5/2001 10:45:48 AM ******/
CREATE PROCEDURE dbo.bbListSelectCommand
AS
	SET NOCOUNT ON;
SELECT ListID, ListName FROM List

GO
