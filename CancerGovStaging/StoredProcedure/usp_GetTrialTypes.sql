IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetTrialTypes]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetTrialTypes]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE usp_GetTrialTypes AS

SELECT 	DISTINCT T.TypeID, T.[Name], T.SourceID, T.[Name] + ';' + CONVERT(varchar(15), T.SourceID) AS TypeInfo
FROM		ProtocolType TT,
		Type T
WHERE 	T.TypeID = TT.Type AND T.[Name] IN ('treatment','prevention','diagnostic','genetics','screening','supportive care')
ORDER BY 	T.TypeID

GO
