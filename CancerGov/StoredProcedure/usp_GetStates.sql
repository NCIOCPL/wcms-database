IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetStates]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetStates]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE usp_GetStates 
AS
BEGIN
	--U.S. States
	(SELECT State.ShortName + ' - ' + State.[Name] AS State, 
		State.StateID, 
		State.CountryID, 
		State.[Name] + ";" + CONVERT(varchar(36), State.StateID) AS StateInfo
	FROM 	State INNER JOIN Country 
		ON State.CountryID = Country.CountryID 
	WHERE State.[Name] <> 'All States' 
		AND Country.[Name] = 'U.S.A.')
	ORDER BY StateInfo
END

GO
