IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetCountries]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetCountries]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE usp_GetCountries 
AS
BEGIN
	SELECT [Name] As Country, 
		CountryID, [Name] + ';' + CONVERT(varchar(36), CountryID) AS CountryInfo, 
		Priority = 1
	FROM COUNTRY 
	WHERE [Name] = 'U.S.A.'
	UNION
	SELECT [Name] As Country, 
		CountryID, [Name] + ';' + CONVERT(varchar(36), 
		CountryID) AS CountryInfo, 
		Priority = 2
	FROM COUNTRY 
	WHERE [Name] <> 'U.S.A.'
	ORDER By Priority, Country
END

GO
