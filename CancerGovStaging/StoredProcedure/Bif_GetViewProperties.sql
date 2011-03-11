IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Bif_GetViewProperties]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[Bif_GetViewProperties]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE dbo.Bif_GetViewProperties
	@NVI  as uniqueidentifier
AS
SELECT  ViewProperty.PropertyName,  ViewProperty.PropertyValue 
FROM ViewProperty
WHERE ViewProperty.NCIViewID = @NVI
GO
