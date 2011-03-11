IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[vwUSAProtocolTrialSite]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vwUSAProtocolTrialSite]
GO
/****** Object:  View dbo.vwUSAProtocolTrialSite    Script Date: 7/5/2006 2:15:46 PM ******/

CREATE view [dbo].[vwUSAProtocolTrialSite]
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
	zip, longitude, latitude
from dbo.protocolTrialSite ts inner join dbo.zipcodes z on isNULL(ts.zip,0)  = z.zipcode
 where country = 'U.S.A.'


GO
