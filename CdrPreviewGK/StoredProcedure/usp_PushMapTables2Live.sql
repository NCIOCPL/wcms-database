IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_PushMapTables2Live]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_PushMapTables2Live]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure DBO.usp_PushMapTables2Live
@isdebug bit = 0
as
Begin

	----Check

		if exists( select * from cdrliveGK.dbo.alternateIDtype live inner join cdrPreviewGK.dbo.alternateIDtype preview
				on live.IDtypeID = preview.IDtypeID where live.idtype <> preview.idtype)
			begin 
				raiserror(69999, 16, 1 , 'AlternateIDType') 
				return 69999
			end
		
		if exists( select * from cdrliveGK.dbo.Sponsor live inner join cdrPreviewGK.dbo.Sponsor preview
				on live.SponsorID = preview.SponsorID where live.Sponsorname <> preview.Sponsorname)
			begin 
				raiserror(69999, 16, 1 , 'Sponsor') 
				return 69999
			end

		if exists( select * from cdrliveGK.dbo.studycategory live inner join cdrPreviewGK.dbo.studyCategory preview
				on live.StudycategoryID = preview.StudyCategoryID where live.StudyCategoryname <> preview.Studycategoryname)
			begin 
				raiserror(69999, 16, 1 , 'StudyCategory') 
				return 69999
			end	

--		if exists( select * from cdrliveGK.dbo.modality live inner join cdrPreviewGK.dbo.Modality preview
--				on live.ModalityID = preview.ModalityID where live.Modalityname <> preview.Modalityname)
--			begin 
--				raiserror(69999, 16, 1 , 'Modality') 
--				return 69999
--			end


	---Insert alternateIDtype
		insert into CDRLiveGK.dbo.AlternateIDtype (idtypeID,idtype)
		select p.IDtypeID, p.idtype 
			from CDRPreviewGK.dbo.AlternateIDType p
				left outer join CDRLiveGK.dbo.AlternateIDType l
				on p.idtype = l.idtype 
			where l.idtype is null
		if @@ERROR > 0 
			begin
				raiserror(69999, 16, 1 , 'AlternateIDType') 
				return 69999
			end

		--Insert Sponsor
		insert into CDRLiveGK.dbo.sponsor (sponsorid, sponsorname)
		select p.sponsorID,p.sponsorname 
			from CDRPreviewGK.dbo.Sponsor p
				left outer join CDRLiveGK.dbo.sponsor l
				on p.sponsorname  = l.sponsorname  
			where l.sponsorname  is null
		if @@ERROR > 0 
			begin 
				raiserror(69999, 16, 1 , 'Sponsor') 
				return 69999
			end
		

		--Insert Modality
		insert into CDRLiveGK.dbo.modality (modalityid, modalityname)
		select p.modalityid, p.modalityname
			from CDRPreviewGK.dbo.modality p
				left outer join CDRLiveGK.dbo.modality l
				on p.modalityName  = l.modalityName and p.modalityID = l.modalityID
			where l.modalityid  is null
		if @@ERROR > 0 
			begin
				raiserror(69999, 16, 1 , 'Modality') 
				return 69999
			end


		--Insert Studycategory a.k.a type of trial
		insert into CDRLiveGK.dbo.studyCategory (studycategoryID, studycategoryName)
		select p.studycategoryID, p.studycategoryname
			from CDRPreviewGK.dbo.studycategory p
				left outer join CDRLiveGK.dbo.studycategory l
				on p.studycategoryname   = l.studycategoryname
			where l.studycategoryname  is null

		if @@ERROR > 0 
			begin
				raiserror(69999, 16, 1 , 'StudyCategory') 
				return 69999
			end
		

	
	
	
end

GO
GRANT EXECUTE ON [dbo].[usp_PushMapTables2Live] TO [Gatekeeper_role]
GO
