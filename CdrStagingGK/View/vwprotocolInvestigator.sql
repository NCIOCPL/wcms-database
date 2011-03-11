IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[vwprotocolInvestigator]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vwprotocolInvestigator]
GO


/****** Object:  View dbo.vwProtocolInvestigator    Script Date: 7/5/2006 2:15:46 PM ******/
CREATE VIEW dbo.vwprotocolInvestigator
AS

SELECT     
	ProtocolID, 
	protocolcontactinfoID,
	PersonID, 
	PersonGivenName, 
	PersonSurName As [NAME], 
	PersonSurName As DisplayName, 
	PersonSurName, 
	PersonProfessionalSuffix, 
	City, 
	State, 
	Country,
	organizationid
FROM       dbo.protocoltrialsite
union ALL
SELECT    
	protocolID,
	protocolcontactinfoID,
	PersonID, 
	PersonGivenName, 
	PersonSurName As [NAME], 
	PersonSurName As DisplayName, 
	PersonSurName, 
	PersonProfessionalSuffix, 
	City, 
	State, 
	Country,
	organizationid
FROM       dbo.Protocolleadorg





GO
