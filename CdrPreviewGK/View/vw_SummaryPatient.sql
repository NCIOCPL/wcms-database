IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[vw_SummaryPatient]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vw_SummaryPatient]
GO

CREATE view [dbo].[vw_SummaryPatient]
as

select d.DocumentID, d.DocumentGUID,  d.Version,
			 s.Type, s.Language, s.Title
from Document d, Summary s
where d.DocumentID = s.SummaryID
and d.IsActive = 1
and Audience = 'Patients'


GO
GRANT SELECT ON [dbo].[vw_SummaryPatient] TO [webAdminUser_role]
GO
GRANT SELECT ON [dbo].[vw_SummaryPatient] ([DocumentID]) TO [webAdminUser_role]
GO
GRANT SELECT ON [dbo].[vw_SummaryPatient] ([DocumentGUID]) TO [webAdminUser_role]
GO
GRANT SELECT ON [dbo].[vw_SummaryPatient] ([Version]) TO [webAdminUser_role]
GO
GRANT SELECT ON [dbo].[vw_SummaryPatient] ([Type]) TO [webAdminUser_role]
GO
GRANT SELECT ON [dbo].[vw_SummaryPatient] ([Language]) TO [webAdminUser_role]
GO
GRANT SELECT ON [dbo].[vw_SummaryPatient] ([Title]) TO [webAdminUser_role]
GO
