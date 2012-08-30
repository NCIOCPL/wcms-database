IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_GenericModule_GetAllAssemblies]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_GenericModule_GetAllAssemblies]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_GenericModule_GetAllAssemblies
AS
BEGIN

	SELECT distinct AssemblyName
	FROM (
		select AssemblyName from GenericModule
		UNION
		select EditAssemblyName as AssemblyName from GenericModule
	) a
	WHERE AssemblyName is not null

END

GO
GRANT EXECUTE ON [dbo].[Core_GenericModule_GetAllAssemblies] TO [websiteuser_role]
GO
