IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[vwUSAProtocolContactInfo]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vwUSAProtocolContactInfo]
GO

CREATE view [dbo].[vwUSAProtocolContactInfo]
with schemabinding
as

select [ProtocolContactInfoID]  ,
	[ProtocolID] ,
	[OrganizationID],
	[PersonID] ,
	[OrganizationName] ,
	[PersonGivenName] ,
	[PersonSurName] ,
	[PersonProfessionalSuffix] ,
	--[PhoneNumber] ,
	--[PersonRole] ,
	[OrganizationRole] ,
	[City] ,
	[State] ,
	--[StateFullName],
	--[StateID] ,
	[Country] ,
	--[PostalCodeZIP],
	zip
from dbo.protocolTrialSite 
where country = 'U.S.A.'

 

GO
