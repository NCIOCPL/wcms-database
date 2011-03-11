IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetProtocolInstitutionsByID]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetProtocolInstitutionsByID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE dbo.usp_GetProtocolInstitutionsByID

	     @IDList varchar(4000)

AS
BEGIN

	Declare @InstitutionIDs Table(item int)

	insert into @InstitutionIDs
	select objectID from udf_GetComaSeparatedIDs(@IDList)



	select organizationid as cdrid, name,
		name + ', ' + 
		(select top 1 city +  ', ' + State from dbo.protocoltrialsite t
			where t.organizationid = o.organizationid AND 
			(((Country = 'U.S.A.' OR Country = 'Canada') AND NULLIF(State, '') IS NOT NULL) OR
			 ((Country <> 'U.S.A.' AND Country <> 'Canada') OR NULLIF(State, '') IS NULL))
	)
		as Displayname
	from organizationname o
	where organizationid in (select item from @InstitutionIDs)
	and type = 'OfficialName'


END
GO
GRANT EXECUTE ON [dbo].[usp_GetProtocolInstitutionsByID] TO [websiteuser_role]
GO
