IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ProtocolStudyContact]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[ProtocolStudyContact]
GO

CREATE VIEW dbo.ProtocolStudyContact
AS

SELECT ProtocolID, PersonID, OrganizationID, CountryID, StateID, Country, State, City, OrganizationName, PersonName, PhoneNumber, OrgInfo, 
               UpdateDate, UpdateUserID
FROM  CancerGov.dbo.ProtocolStudyContact


GO
