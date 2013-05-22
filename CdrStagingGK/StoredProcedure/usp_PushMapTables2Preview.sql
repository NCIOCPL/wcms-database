IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_PushMapTables2Preview]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_PushMapTables2Preview]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure DBO.usp_PushMapTables2Preview
@isdebug bit = 0
as
Begin
		if exists( select * from CDRPreviewGK.dbo.alternateIDtype live inner join cdrStagingGK.dbo.alternateIDtype preview
				on Preview.IDtypeID = preview.IDtypeID where Preview.idtype <> preview.idtype)
			begin 
				raiserror(69999, 16, 1 , 'AlternateIDType') 
				return 69999
			end
		
		if exists( select * from CDRPreviewGK.dbo.Sponsor live inner join cdrStagingGK.dbo.Sponsor preview
				on Preview.SponsorID = preview.SponsorID where Preview.Sponsorname <> preview.Sponsorname)
			begin 
				raiserror(69999, 16, 1 , 'Sponsor') 
				return 69999
			end

		if exists( select * from CDRPreviewGK.dbo.studycategory live inner join cdrStagingGK.dbo.studyCategory preview
				on Preview.StudycategoryID = preview.StudyCategoryID where Preview.StudyCategoryname <> preview.Studycategoryname)
			begin 
				raiserror(69999, 16, 1 , 'StudyCategory') 
				return 69999
			end	

--		if exists( select * from CDRPreviewGK.dbo.modality live inner join cdrStagingGK.dbo.Modality preview
--				on Preview.ModalityID = preview.ModalityID where Preview.Modalityname <> preview.Modalityname)
--			begin 
--				raiserror(69999, 16, 1 , 'Modality') 
--				return 69999
--			end


	---Insert alternateIDtype
		insert into CDRPreviewGK.dbo.AlternateIDtype (idtypeID,idtype)
		select p.IDtypeID, p.idtype 
			from CDRStagingGK.dbo.AlternateIDType p
				left outer join CDRPreviewGK.dbo.AlternateIDType l
				on p.idtype = l.idtype 
			where l.idtype is null
		if @@ERROR > 0 
			begin
				raiserror(69999, 16, 1 , 'AlternateIDType') 
				return 69999
			end

		--Insert Sponsor
		insert into CDRPreviewGK.dbo.sponsor (sponsorid, sponsorname)
		select p.sponsorID,p.sponsorname 
			from CDRStagingGK.dbo.Sponsor p
				left outer join CDRPreviewGK.dbo.sponsor l
				on p.sponsorname  = l.sponsorname  
			where l.sponsorname  is null
		if @@ERROR > 0 
			begin 
				raiserror(69999, 16, 1 , 'Sponsor') 
				return 69999
			end
		

		--Insert Modality
		insert into CDRPreviewGK.dbo.modality (modalityid, modalityname)
		select p.modalityid, p.modalityname
			from CDRStagingGK.dbo.modality p
				left outer join CDRPreviewGK.dbo.modality l
				on p.modalityName  = l.modalityName and p.modalityID = l.modalityID
			where l.modalityid  is null
		if @@ERROR > 0 
			begin
				raiserror(69999, 16, 1 , 'Modality') 
				return 69999
			end


		--Insert Studycategory a.k.a type of trial
		insert into CDRPreviewGK.dbo.studyCategory (studycategoryID, studycategoryName)
		select p.studycategoryID, p.studycategoryname
			from CDRStagingGK.dbo.studycategory p
				left outer join CDRPreviewGK.dbo.studycategory l
				on p.studycategoryname   = l.studycategoryname
			where l.studycategoryname  is null

		if @@ERROR > 0 
			begin
				raiserror(69999, 16, 1 , 'StudyCategory') 
				return 69999
			end
		
	
end

GO
GRANT EXECUTE ON [dbo].[usp_PushMapTables2Preview] TO [Gatekeeper_role]
GO
