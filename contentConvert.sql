use Percussion

if OBJECT_ID('gaoLandingToArticle') is not null
	Drop procedure dbo.gaoLandingtoarticle
GO
create procedure dbo.gaoLandingToArticle(@contentid int)
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN
		
		insert into CT_CGVARTICLE1(CONTENTID, REVISIONID)
			select CONTENTID, REVISIONID 
			from CT_NCILANDINGPAGE where CONTENTID = @contentid 
			
			--- update content type
			update CONTENTSTATUS 
			set contenttypeid = (select CONTENTTYPEID from CONTENTTYPES where CONTENTTYPENAME = 'cgvArticle') where CONTENTID = @contentid and CONTENTTYPEID = (select CONTENTTYPEID from CONTENTTYPES where CONTENTTYPENAME = 'nciLandingpage')
			
			delete from CT_NCILANDINGPAGE where CONTENTID = @contentid 

			Commit 
	END TRY
	BEGIN CATCH
			SELECT @contentid
					, ERROR_NUMBER() AS ErrorNumber
					,ERROR_SEVERITY() AS ErrorSeverity
					,ERROR_STATE() AS ErrorState
					,ERROR_PROCEDURE() AS ErrorProcedure
					,ERROR_LINE() AS ErrorLine
					,ERROR_MESSAGE() AS ErrorMessage;
				Rollback
	END CATCH 
		
END 
GO




--general to topic
if OBJECT_ID('gaoGeneralToLanding') is not null
	Drop procedure dbo.gaoGeneralToLanding
GO
create procedure dbo.gaoGeneralToLanding(@contentid int)
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN
		
		insert into CT_NCILANDINGPAGE(CONTENTID, REVISIONID
			, NVCG_TEMPLATE
			, cgv_template
			, TYPE
			, LANDING_PAGE_TYPE,  MOBILEBODYFIELD, CGV_M_TEMPLATE)
			select CONTENTID, REVISIONID 
			,'nvcgPgHomePage'
			,'portal'
			,'ncilandingpage'
			, 'two_columns',  MOBILEBODYFIELD, CGV_M_TEMPLATE
			from CT_CGVSINGLEPAGECONTENT where CONTENTID = @contentid 
			
			--- update content type
			update CONTENTSTATUS 
			set contenttypeid = (select CONTENTTYPEID from CONTENTTYPES where CONTENTTYPENAME = 'nciLandingpage') where CONTENTID = @contentid and CONTENTTYPEID = (select CONTENTTYPEID from CONTENTTYPES where CONTENTTYPENAME = 'ncigeneral')
			
			delete from CT_CGVSINGLEPAGECONTENT where CONTENTID = @contentid 

			Commit 
	END TRY
	BEGIN CATCH
			SELECT @contentid
					, ERROR_NUMBER() AS ErrorNumber
					,ERROR_SEVERITY() AS ErrorSeverity
					,ERROR_STATE() AS ErrorState
					,ERROR_PROCEDURE() AS ErrorProcedure
					,ERROR_LINE() AS ErrorLine
					,ERROR_MESSAGE() AS ErrorMessage;
				Rollback
	END CATCH 
		
END 
GO




--general to topic
if OBJECT_ID('gaoGeneralToTopic') is not null
	Drop procedure dbo.gaoGeneralToTopic
GO
create procedure dbo.gaoGeneralToTopic(@contentid int)
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN
	
			insert into CT_CGVTOPICPAGE(CONTENTID, REVISIONID, NVCG_TEMPLATE)
			select CONTENTID, REVISIONID , 
				case when nvcg_template = 'complex_wide' then 'nvcgDsTopicPageNoLeftNav'
				else 'nvcgDsTopicPageLeftNav' END 
			from CT_CGVSINGLEPAGECONTENT where CONTENTID = @contentid 
			
			--- update content type
			update CONTENTSTATUS 
			set contenttypeid = (select CONTENTTYPEID from CONTENTTYPES where CONTENTTYPENAME = 'cgvTopicPage') where CONTENTID = @contentid and CONTENTTYPEID = (select CONTENTTYPEID from CONTENTTYPES where CONTENTTYPENAME = 'ncigeneral')
			
			delete from CT_CGVSINGLEPAGECONTENT where CONTENTID = @contentid 

			Commit 
	END TRY
	BEGIN CATCH
			SELECT @contentid
					, ERROR_NUMBER() AS ErrorNumber
					,ERROR_SEVERITY() AS ErrorSeverity
					,ERROR_STATE() AS ErrorState
					,ERROR_PROCEDURE() AS ErrorProcedure
					,ERROR_LINE() AS ErrorLine
					,ERROR_MESSAGE() AS ErrorMessage;
				Rollback
	END CATCH 
		
END 
GO
---------------


---general to article
if OBJECT_ID('gaoGeneralToArticle') is not null
	Drop procedure dbo.gaoGeneralToArticle
GO
create procedure dbo.gaoGeneralToArticle(@contentid int)
AS
BEGIN

	BEGIN TRY
		BEGIN TRAN
		
			insert into CT_CGVARTICLE1(CONTENTID, REVISIONID)
			select CONTENTID, REVISIONID 
			from CT_CGVSINGLEPAGECONTENT where CONTENTID = @contentid 
			
			--- update content type
			update CONTENTSTATUS 
			set contenttypeid = (select CONTENTTYPEID from CONTENTTYPES where CONTENTTYPENAME = 'cgvArticle') where CONTENTID = @contentid and CONTENTTYPEID = (select CONTENTTYPEID from CONTENTTYPES where CONTENTTYPENAME = 'ncigeneral')
			
			delete from CT_CGVSINGLEPAGECONTENT where CONTENTID = @contentid 

			Commit 
	END TRY
	BEGIN CATCH
			SELECT @contentid
					, ERROR_NUMBER() AS ErrorNumber
					,ERROR_SEVERITY() AS ErrorSeverity
					,ERROR_STATE() AS ErrorState
					,ERROR_PROCEDURE() AS ErrorProcedure
					,ERROR_LINE() AS ErrorLine
					,ERROR_MESSAGE() AS ErrorMessage;
				Rollback
	END CATCH 
		
END 
GO
---------------




--- Landing to general
if OBJECT_ID('gaoLandingToGeneral') is not null
	Drop procedure dbo.gaoLandingToGeneral
GO
Create procedure dbo.gaoLandingToGeneral(@contentid int)
AS
BEGIN

	BEGIN TRY
		BEGIN TRAN
			insert into  dbo.CT_CGVSINGLEPAGECONTENT(CONTENTID, REVISIONID
			, TYPE, DISPLAY_TEMPLATE
			, NVCG_TEMPLATE
			, MOBILEBODYFIELD, CGV_M_TEMPLATE) 
			select contentid , revisionid
			, 'nciGeneral',  'tcgaPgGeneral' 
			 , case when CGV_TEMPLATE ='no_left_nav' then  'complex_wide'
			else  'complex' END 
			, MOBILEBODYFIELD, CGV_M_TEMPLATE
			from dbo.CT_NCILANDINGPAGE where CONTENTID = @contentid 

			--- update content type
			update CONTENTSTATUS 
			set contenttypeid = (select CONTENTTYPEID from CONTENTTYPES where CONTENTTYPENAME = 'nciGeneral') where CONTENTID = @contentid and CONTENTTYPEID = (select CONTENTTYPEID from CONTENTTYPES where CONTENTTYPENAME = 'ncilandingpage')
			
			delete from CT_NCILANDINGPAGE where CONTENTID = @contentid 
			
			Commit 
	END TRY
	BEGIN CATCH
			SELECT @contentid
					, ERROR_NUMBER() AS ErrorNumber
					,ERROR_SEVERITY() AS ErrorSeverity
					,ERROR_STATE() AS ErrorState
					,ERROR_PROCEDURE() AS ErrorProcedure
					,ERROR_LINE() AS ErrorLine
					,ERROR_MESSAGE() AS ErrorMessage;
				Rollback
	END CATCH 
		
END 
GO
---------------





---------------------------------------
--landing to topic
--nvcg_template
if OBJECT_ID('gaoLandingToTopic') is not null
	drop procedure dbo.gaoLandingToTopic
GO
create procedure dbo.gaoLandingToTopic(@contentid int)
AS 
BEGIN

	BEGIN TRY
			BEGIN TRAN
			insert into CT_CGVTOPICPAGE (contentid, revisionid , nvcg_template)
			select CONTENTID, REVISIONID
			, case when CGV_TEMPLATE ='no_left_nav' then  'nvcgDsTopicPageNoLeftNav'
			else  'nvcgDsTopicPageLeftNav' END 
			from CT_NCILANDINGPAGE nl 
			where nl.CONTENTID = @contentid

			--syndicate
			insert into CGVSYNDICATION_CGVSYNDICATION1(CONTENTID , REVISIONID)
			select CONTENTID, REVISIONID
			from ct_ncilandingpage nl where CONTENTID = @contentid 

			--- update content type
			update CONTENTSTATUS set contenttypeid = (select CONTENTTYPEID from CONTENTTYPES where CONTENTTYPENAME = 'cgvTopicPage') where CONTENTID = @contentid and CONTENTTYPEID = (select CONTENTTYPEID from CONTENTTYPES where CONTENTTYPENAME = 'ncilandingpage')
			
			delete from CT_NCILANDINGPAGE where CONTENTID = @contentid 
			
			Commit 
	END TRY
	BEGIN CATCH
			SELECT @contentid
					, ERROR_NUMBER() AS ErrorNumber
					,ERROR_SEVERITY() AS ErrorSeverity
					,ERROR_STATE() AS ErrorState
					,ERROR_PROCEDURE() AS ErrorProcedure
					,ERROR_LINE() AS ErrorLine
					,ERROR_MESSAGE() AS ErrorMessage;
				Rollback
	END CATCH 
		
END


GO



exec dbo.gaolandingtotopic 173034
exec dbo.gaolandingtotopic 173035
exec dbo.gaolandingtotopic 173036
exec dbo.gaolandingtotopic 173038
exec dbo.gaolandingtotopic 173039
exec dbo.gaolandingtotopic 173042
exec dbo.gaolandingtotopic 173043
exec dbo.gaolandingtotopic 173046
exec dbo.gaolandingtotopic 173047
exec dbo.gaolandingtotopic 173067
exec dbo.gaolandingtotopic 173077
exec dbo.gaolandingtotopic 173087
exec dbo.gaolandingtotopic 173088
exec dbo.gaolandingtotopic 173108
exec dbo.gaolandingtotopic 173118
exec dbo.gaolandingtotopic 178893
exec dbo.gaolandingtotopic 199598
exec dbo.gaolandingtotopic 201448
exec dbo.gaolandingtotopic 420613
exec dbo.gaolandingtotopic 420620
exec dbo.gaolandingtotopic 420635
exec dbo.gaolandingtotopic 420653
exec dbo.gaolandingtotopic 420655
exec dbo.gaolandingtotopic 420714
exec dbo.gaolandingtotopic 434558
exec dbo.gaolandingtotopic 434607
exec dbo.gaolandingtotopic 434744
exec dbo.gaolandingtotopic 435649
exec dbo.gaolandingtotopic 435654
exec dbo.gaolandingtotopic 435659
exec dbo.gaolandingtotopic 402367
exec dbo.gaolandingtotopic 417052
exec dbo.gaolandingtotopic 417716
exec dbo.gaolandingtotopic 580625
exec dbo.gaolandingtotopic 580763
exec dbo.gaolandingtotopic 581939
exec dbo.gaolandingtotopic 608383
exec dbo.gaolandingtotopic 617671
exec dbo.gaolandingtotopic 617672
exec dbo.gaolandingtotopic 617673
exec dbo.gaolandingtotopic 617700
exec dbo.gaolandingtotopic 613877
exec dbo.gaolandingtotopic 634256
exec dbo.gaolandingtotopic 710912
exec dbo.gaolandingtotopic 710913
exec dbo.gaolandingtotopic 710914
exec dbo.gaolandingtotopic 710915
exec dbo.gaolandingtotopic 898467
exec dbo.gaolandingtotopic 802717
exec dbo.gaolandingtotopic 915971
exec dbo.gaolandingtotopic 16365
exec dbo.gaolandingtotopic 883849
exec dbo.gaolandingtotopic 929550
exec dbo.gaolandingtotopic 911134
exec dbo.gaolandingtotopic 581480
exec dbo.gaolandingtotopic 14503
exec dbo.gaolandingtotopic 198130
exec dbo.gaolandingtotopic 13067
exec dbo.gaolandingtotopic 14369
exec dbo.gaolandingtotopic 12955
exec dbo.gaolandingtotopic 15606
exec dbo.gaolandingtotopic 15063
exec dbo.gaolandingtotopic 13741
exec dbo.gaolandingtotopic 13428
exec dbo.gaolandingtotopic 13881
exec dbo.gaolandingtotopic 911505
exec dbo.gaolandingtotopic 901508
exec dbo.gaolandingtotopic 922638
exec dbo.gaolandingtotopic 76317
exec dbo.gaolandingtotopic 151007
exec dbo.gaolandingtotopic 151004
exec dbo.gaolandingtotopic 610566
exec dbo.gaolandingtotopic 106628
exec dbo.gaolandingtotopic 151005
exec dbo.gaolandingtotopic 151003
exec dbo.gaolandingtotopic 151001
exec dbo.gaolandingtotopic 452717
exec dbo.gaolandingtotopic 150999
exec dbo.gaolandingtotopic 151006
exec dbo.gaolandingtotopic 914804
exec dbo.gaolandingtotopic 916766
exec dbo.gaolandingtotopic 915271
exec dbo.gaolandingtotopic 914801
exec dbo.gaolandingtotopic 914833
exec dbo.gaolandingtotopic 916849
exec dbo.gaolandingtotopic 16360
exec dbo.gaolandingtotopic 13474
exec dbo.gaolandingtotopic 919000
exec dbo.gaolandingtotopic 16371
exec dbo.gaolandingtotopic 917286
exec dbo.gaolandingtotopic 917517
exec dbo.gaolandingtotopic 922315
exec dbo.gaolandingtotopic 15065
exec dbo.gaolandingtotopic 858012
exec dbo.gaolandingtotopic 859574
exec dbo.gaolandingtotopic 859562
exec dbo.gaolandingtotopic 859582
exec dbo.gaolandingtotopic 321607
exec dbo.gaolandingtotopic 866280
exec dbo.gaolandingtotopic 840767
exec dbo.gaolandingtotopic 828020
exec dbo.gaolandingtotopic 747150
exec dbo.gaolandingtotopic 768882
exec dbo.gaolandingtotopic 867853
exec dbo.gaolandingtotopic 776914
exec dbo.gaolandingtotopic 16363
exec dbo.gaolandingtotopic 608324
exec dbo.gaolandingtotopic 922513
exec dbo.gaolandingtotopic 930168
exec dbo.gaolandingtotopic 915591
exec dbo.gaolandingtotopic 267255
exec dbo.gaolandingtotopic 916695
exec dbo.gaolandingtotopic 866188
exec dbo.gaolandingtotopic 916661
exec dbo.gaolandingtotopic 818142
exec dbo.gaolandingtotopic 916701
exec dbo.gaolandingtotopic 921990
exec dbo.gaolandingtotopic 922330
exec dbo.gaolandingtotopic 15554
exec dbo.gaolandingtotopic 918974
exec dbo.gaolandingtotopic 912884
exec dbo.gaolandingtotopic 326169
exec dbo.gaolandingtotopic 915080


exec dbo.gaolandingtogeneral 176775
exec dbo.gaolandingtogeneral 177549
exec dbo.gaolandingtogeneral 280777


exec dbo.gaogeneralToTopic 14930
exec dbo.gaogeneralToTopic 804515
exec dbo.gaogeneralToTopic 804516
exec dbo.gaogeneralToTopic 804517
exec dbo.gaogeneralToTopic 14689
exec dbo.gaogeneralToTopic 883453
exec dbo.gaogeneralToTopic 13054
exec dbo.gaogeneralToTopic 15853
exec dbo.gaogeneralToTopic 915271
exec dbo.gaogeneralToTopic 914801
exec dbo.gaogeneralToTopic 914833
exec dbo.gaogeneralToTopic 833173
exec dbo.gaogeneralToTopic 847972
exec dbo.gaogeneralToTopic 833192
exec dbo.gaogeneralToTopic 747173
exec dbo.gaogeneralToTopic 810260
exec dbo.gaogeneralToTopic 63861
exec dbo.gaogeneralToTopic 905791
exec dbo.gaogeneralToTopic 14257
exec dbo.gaogeneralToTopic 799546
exec dbo.gaogeneralToTopic 816922
exec dbo.gaogeneralToTopic 799373
exec dbo.gaogeneralToTopic 16169
exec dbo.gaogeneralToTopic 12954
exec dbo.gaogeneralToTopic 14034
exec dbo.gaogeneralToTopic 15132
exec dbo.gaogeneralToTopic 63867
exec dbo.gaogeneralToTopic 916945
exec dbo.gaogeneralToTopic 13795
exec dbo.gaogeneralToTopic 794087
exec dbo.gaogeneralToTopic 13792
exec dbo.gaogeneralToTopic 105818
exec dbo.gaogeneralToTopic 14879


exec dbo.gaogeneraltoarticle 12872
exec dbo.gaogeneraltoarticle 12989
exec dbo.gaogeneraltoarticle 13003
exec dbo.gaogeneraltoarticle 13022
exec dbo.gaogeneraltoarticle 13106
exec dbo.gaogeneraltoarticle 13306
exec dbo.gaogeneraltoarticle 13314
exec dbo.gaogeneraltoarticle 13432
exec dbo.gaogeneraltoarticle 13440
exec dbo.gaogeneraltoarticle 13473
exec dbo.gaogeneraltoarticle 13782
exec dbo.gaogeneraltoarticle 13925
exec dbo.gaogeneraltoarticle 15059
exec dbo.gaogeneraltoarticle 15309
exec dbo.gaogeneraltoarticle 15395
exec dbo.gaogeneraltoarticle 15686
exec dbo.gaogeneraltoarticle 65958
exec dbo.gaogeneraltoarticle 65990
exec dbo.gaogeneraltoarticle 68382
exec dbo.gaogeneraltoarticle 12997
exec dbo.gaogeneraltoarticle 12998
exec dbo.gaogeneraltoarticle 13021
exec dbo.gaogeneraltoarticle 13372
exec dbo.gaogeneraltoarticle 13974
exec dbo.gaogeneraltoarticle 13982
exec dbo.gaogeneraltoarticle 14215
exec dbo.gaogeneraltoarticle 14375
exec dbo.gaogeneraltoarticle 14835
exec dbo.gaogeneraltoarticle 15010
exec dbo.gaogeneraltoarticle 15069
exec dbo.gaogeneraltoarticle 15468
exec dbo.gaogeneraltoarticle 15621
exec dbo.gaogeneraltoarticle 15685
exec dbo.gaogeneraltoarticle 15747
exec dbo.gaogeneraltoarticle 15821
exec dbo.gaogeneraltoarticle 16279
exec dbo.gaogeneraltoarticle 65884
exec dbo.gaogeneraltoarticle 65973
exec dbo.gaogeneraltoarticle 13186
exec dbo.gaogeneraltoarticle 13193
exec dbo.gaogeneraltoarticle 13294
exec dbo.gaogeneraltoarticle 13392
exec dbo.gaogeneraltoarticle 13645
exec dbo.gaogeneraltoarticle 13720
exec dbo.gaogeneraltoarticle 13760
exec dbo.gaogeneraltoarticle 14078
exec dbo.gaogeneraltoarticle 14143
exec dbo.gaogeneraltoarticle 14553
exec dbo.gaogeneraltoarticle 14572
exec dbo.gaogeneraltoarticle 14798
exec dbo.gaogeneraltoarticle 14890
exec dbo.gaogeneraltoarticle 15104
exec dbo.gaogeneraltoarticle 15172
exec dbo.gaogeneraltoarticle 15718
exec dbo.gaogeneraltoarticle 57472
exec dbo.gaogeneraltoarticle 63856
exec dbo.gaogeneraltoarticle 63858
exec dbo.gaogeneraltoarticle 68514
exec dbo.gaogeneraltoarticle 101531
exec dbo.gaogeneraltoarticle 120766
exec dbo.gaogeneraltoarticle 120775
exec dbo.gaogeneraltoarticle 120776
exec dbo.gaogeneraltoarticle 120782
exec dbo.gaogeneraltoarticle 151032
exec dbo.gaogeneraltoarticle 151033
exec dbo.gaogeneraltoarticle 326530
exec dbo.gaogeneraltoarticle 331376
exec dbo.gaogeneraltoarticle 420528
exec dbo.gaogeneraltoarticle 420531
exec dbo.gaogeneraltoarticle 479140
exec dbo.gaogeneraltoarticle 488735
exec dbo.gaogeneraltoarticle 678485
exec dbo.gaogeneraltoarticle 679331
exec dbo.gaogeneraltoarticle 65947
exec dbo.gaogeneraltoarticle 68379
exec dbo.gaogeneraltoarticle 78747
exec dbo.gaogeneraltoarticle 82014
exec dbo.gaogeneraltoarticle 102654
exec dbo.gaogeneraltoarticle 109373
exec dbo.gaogeneraltoarticle 120771
exec dbo.gaogeneraltoarticle 151036
exec dbo.gaogeneraltoarticle 151038
exec dbo.gaogeneraltoarticle 170976
exec dbo.gaogeneraltoarticle 326525
exec dbo.gaogeneraltoarticle 326541
exec dbo.gaogeneraltoarticle 326544
exec dbo.gaogeneraltoarticle 420502
exec dbo.gaogeneraltoarticle 420515
exec dbo.gaogeneraltoarticle 420524
exec dbo.gaogeneraltoarticle 68415
exec dbo.gaogeneraltoarticle 112133
exec dbo.gaogeneraltoarticle 112300
exec dbo.gaogeneraltoarticle 151040
exec dbo.gaogeneraltoarticle 151042
exec dbo.gaogeneraltoarticle 171104
exec dbo.gaogeneraltoarticle 177546
exec dbo.gaogeneraltoarticle 298554
exec dbo.gaogeneraltoarticle 326565
exec dbo.gaogeneraltoarticle 327274
exec dbo.gaogeneraltoarticle 420512
exec dbo.gaogeneraltoarticle 429220
exec dbo.gaogeneraltoarticle 483058
exec dbo.gaogeneraltoarticle 487344
exec dbo.gaogeneraltoarticle 488040
exec dbo.gaogeneraltoarticle 488732
exec dbo.gaogeneraltoarticle 488734
exec dbo.gaogeneraltoarticle 512107
exec dbo.gaogeneraltoarticle 512339
exec dbo.gaogeneraltoarticle 545378
exec dbo.gaogeneraltoarticle 546264
exec dbo.gaogeneraltoarticle 605836
exec dbo.gaogeneraltoarticle 622407
exec dbo.gaogeneraltoarticle 695232
exec dbo.gaogeneraltoarticle 697262
exec dbo.gaogeneraltoarticle 697265
exec dbo.gaogeneraltoarticle 725751
exec dbo.gaogeneraltoarticle 725775
exec dbo.gaogeneraltoarticle 725782
exec dbo.gaogeneraltoarticle 725792
exec dbo.gaogeneraltoarticle 725793
exec dbo.gaogeneraltoarticle 748303
exec dbo.gaogeneraltoarticle 762658
exec dbo.gaogeneraltoarticle 684821
exec dbo.gaogeneraltoarticle 697303
exec dbo.gaogeneraltoarticle 725750
exec dbo.gaogeneraltoarticle 725783
exec dbo.gaogeneraltoarticle 725784
exec dbo.gaogeneraltoarticle 725791
exec dbo.gaogeneraltoarticle 748346
exec dbo.gaogeneraltoarticle 754654
exec dbo.gaogeneraltoarticle 759574
exec dbo.gaogeneraltoarticle 762633
exec dbo.gaogeneraltoarticle 762657
exec dbo.gaogeneraltoarticle 762659
exec dbo.gaogeneraltoarticle 768977
exec dbo.gaogeneraltoarticle 777531
exec dbo.gaogeneraltoarticle 792791
exec dbo.gaogeneraltoarticle 802443
exec dbo.gaogeneraltoarticle 13320
exec dbo.gaogeneraltoarticle 13362
exec dbo.gaogeneraltoarticle 13516
exec dbo.gaogeneraltoarticle 14467
exec dbo.gaogeneraltoarticle 14908
exec dbo.gaogeneraltoarticle 15595
exec dbo.gaogeneraltoarticle 15769
exec dbo.gaogeneraltoarticle 15839
exec dbo.gaogeneraltoarticle 68408
exec dbo.gaogeneraltoarticle 68483
exec dbo.gaogeneraltoarticle 112142
exec dbo.gaogeneraltoarticle 120765
exec dbo.gaogeneraltoarticle 120767
exec dbo.gaogeneraltoarticle 120768
exec dbo.gaogeneraltoarticle 120773
exec dbo.gaogeneraltoarticle 120774
exec dbo.gaogeneraltoarticle 120781
exec dbo.gaogeneraltoarticle 151034
exec dbo.gaogeneraltoarticle 12925
exec dbo.gaogeneraltoarticle 13209
exec dbo.gaogeneraltoarticle 13644
exec dbo.gaogeneraltoarticle 13778
exec dbo.gaogeneraltoarticle 13829
exec dbo.gaogeneraltoarticle 13943
exec dbo.gaogeneraltoarticle 14244
exec dbo.gaogeneraltoarticle 14304
exec dbo.gaogeneraltoarticle 14587
exec dbo.gaogeneraltoarticle 15305
exec dbo.gaogeneraltoarticle 15349
exec dbo.gaogeneraltoarticle 15355
exec dbo.gaogeneraltoarticle 15491
exec dbo.gaogeneraltoarticle 15600
exec dbo.gaogeneraltoarticle 16226
exec dbo.gaogeneraltoarticle 57471
exec dbo.gaogeneraltoarticle 57473
exec dbo.gaogeneraltoarticle 57474
exec dbo.gaogeneraltoarticle 59028
exec dbo.gaogeneraltoarticle 65964
exec dbo.gaogeneraltoarticle 802753
exec dbo.gaogeneraltoarticle 804564
exec dbo.gaogeneraltoarticle 804565
exec dbo.gaogeneraltoarticle 804689
exec dbo.gaogeneraltoarticle 804750
exec dbo.gaogeneraltoarticle 804751
exec dbo.gaogeneraltoarticle 814466
exec dbo.gaogeneraltoarticle 816967
exec dbo.gaogeneraltoarticle 817099
exec dbo.gaogeneraltoarticle 819881
exec dbo.gaogeneraltoarticle 820126
exec dbo.gaogeneraltoarticle 821962
exec dbo.gaogeneraltoarticle 821964
exec dbo.gaogeneraltoarticle 821970
exec dbo.gaogeneraltoarticle 822287
exec dbo.gaogeneraltoarticle 457193
exec dbo.gaogeneraltoarticle 484116
exec dbo.gaogeneraltoarticle 487870
exec dbo.gaogeneraltoarticle 488505
exec dbo.gaogeneraltoarticle 488731
exec dbo.gaogeneraltoarticle 488737
exec dbo.gaogeneraltoarticle 488911
exec dbo.gaogeneraltoarticle 512203
exec dbo.gaogeneraltoarticle 512275
exec dbo.gaogeneraltoarticle 545310
exec dbo.gaogeneraltoarticle 546085
exec dbo.gaogeneraltoarticle 546272
exec dbo.gaogeneraltoarticle 570077
exec dbo.gaogeneraltoarticle 583446
exec dbo.gaogeneraltoarticle 637652
exec dbo.gaogeneraltoarticle 13386
exec dbo.gaogeneraltoarticle 13627
exec dbo.gaogeneraltoarticle 13704
exec dbo.gaogeneraltoarticle 13751
exec dbo.gaogeneraltoarticle 14028
exec dbo.gaogeneraltoarticle 14352
exec dbo.gaogeneraltoarticle 14545
exec dbo.gaogeneraltoarticle 15113
exec dbo.gaogeneraltoarticle 15181
exec dbo.gaogeneraltoarticle 15817
exec dbo.gaogeneraltoarticle 16143
exec dbo.gaogeneraltoarticle 57470
exec dbo.gaogeneraltoarticle 65887
exec dbo.gaogeneraltoarticle 78748
exec dbo.gaogeneraltoarticle 120770
exec dbo.gaogeneraltoarticle 120772
exec dbo.gaogeneraltoarticle 151035
exec dbo.gaogeneraltoarticle 326536
exec dbo.gaogeneraltoarticle 777775
exec dbo.gaogeneraltoarticle 802442
exec dbo.gaogeneraltoarticle 804566
exec dbo.gaogeneraltoarticle 804567
exec dbo.gaogeneraltoarticle 804933
exec dbo.gaogeneraltoarticle 816965
exec dbo.gaogeneraltoarticle 819784
exec dbo.gaogeneraltoarticle 819883
exec dbo.gaogeneraltoarticle 819939
exec dbo.gaogeneraltoarticle 819941
exec dbo.gaogeneraltoarticle 819948
exec dbo.gaogeneraltoarticle 821979
exec dbo.gaogeneraltoarticle 822305
exec dbo.gaogeneraltoarticle 826658
exec dbo.gaogeneraltoarticle 826661
exec dbo.gaogeneraltoarticle 68353
exec dbo.gaogeneraltoarticle 68595
exec dbo.gaogeneraltoarticle 68601
exec dbo.gaogeneraltoarticle 109064
exec dbo.gaogeneraltoarticle 109372
exec dbo.gaogeneraltoarticle 120769
exec dbo.gaogeneraltoarticle 120777
exec dbo.gaogeneraltoarticle 120778
exec dbo.gaogeneraltoarticle 120779
exec dbo.gaogeneraltoarticle 120780
exec dbo.gaogeneraltoarticle 151037
exec dbo.gaogeneraltoarticle 230011
exec dbo.gaogeneraltoarticle 326568
exec dbo.gaogeneraltoarticle 396060
exec dbo.gaogeneraltoarticle 396077
exec dbo.gaogeneraltoarticle 419029
exec dbo.gaogeneraltoarticle 151039
exec dbo.gaogeneraltoarticle 151041
exec dbo.gaogeneraltoarticle 151058
exec dbo.gaogeneraltoarticle 172407
exec dbo.gaogeneraltoarticle 177547
exec dbo.gaogeneraltoarticle 177548
exec dbo.gaogeneraltoarticle 216653
exec dbo.gaogeneraltoarticle 267291
exec dbo.gaogeneraltoarticle 326305
exec dbo.gaogeneraltoarticle 333439
exec dbo.gaogeneraltoarticle 396061
exec dbo.gaogeneraltoarticle 396064
exec dbo.gaogeneraltoarticle 420505
exec dbo.gaogeneraltoarticle 481162
exec dbo.gaogeneraltoarticle 487763
exec dbo.gaogeneraltoarticle 396065
exec dbo.gaogeneraltoarticle 396117
exec dbo.gaogeneraltoarticle 412019
exec dbo.gaogeneraltoarticle 484117
exec dbo.gaogeneraltoarticle 487752
exec dbo.gaogeneraltoarticle 488736
exec dbo.gaogeneraltoarticle 488738
exec dbo.gaogeneraltoarticle 495557
exec dbo.gaogeneraltoarticle 505574
exec dbo.gaogeneraltoarticle 512109
exec dbo.gaogeneraltoarticle 512234
exec dbo.gaogeneraltoarticle 512237
exec dbo.gaogeneraltoarticle 512244
exec dbo.gaogeneraltoarticle 538214
exec dbo.gaogeneraltoarticle 546210
exec dbo.gaogeneraltoarticle 822290
exec dbo.gaogeneraltoarticle 823316
exec dbo.gaogeneraltoarticle 826233
exec dbo.gaogeneraltoarticle 826390
exec dbo.gaogeneraltoarticle 833184
exec dbo.gaogeneraltoarticle 840730
exec dbo.gaogeneraltoarticle 840848
exec dbo.gaogeneraltoarticle 849846
exec dbo.gaogeneraltoarticle 858328
exec dbo.gaogeneraltoarticle 858336
exec dbo.gaogeneraltoarticle 858339
exec dbo.gaogeneraltoarticle 859575
exec dbo.gaogeneraltoarticle 859583
exec dbo.gaogeneraltoarticle 859634
exec dbo.gaogeneraltoarticle 870528
exec dbo.gaogeneraltoarticle 882436
exec dbo.gaogeneraltoarticle 570076
exec dbo.gaogeneraltoarticle 622403
exec dbo.gaogeneraltoarticle 678040
exec dbo.gaogeneraltoarticle 725754
exec dbo.gaogeneraltoarticle 725778
exec dbo.gaogeneraltoarticle 725779
exec dbo.gaogeneraltoarticle 725786
exec dbo.gaogeneraltoarticle 725787
exec dbo.gaogeneraltoarticle 762663
exec dbo.gaogeneraltoarticle 765018
exec dbo.gaogeneraltoarticle 771748
exec dbo.gaogeneraltoarticle 801796
exec dbo.gaogeneraltoarticle 804586
exec dbo.gaogeneraltoarticle 804753
exec dbo.gaogeneraltoarticle 679052
exec dbo.gaogeneraltoarticle 679249
exec dbo.gaogeneraltoarticle 695704
exec dbo.gaogeneraltoarticle 697302
exec dbo.gaogeneraltoarticle 702842
exec dbo.gaogeneraltoarticle 725752
exec dbo.gaogeneraltoarticle 725753
exec dbo.gaogeneraltoarticle 725777
exec dbo.gaogeneraltoarticle 725788
exec dbo.gaogeneraltoarticle 728762
exec dbo.gaogeneraltoarticle 759773
exec dbo.gaogeneraltoarticle 762655
exec dbo.gaogeneraltoarticle 762661
exec dbo.gaogeneraltoarticle 768980
exec dbo.gaogeneraltoarticle 799332
exec dbo.gaogeneraltoarticle 799372
exec dbo.gaogeneraltoarticle 804754
exec dbo.gaogeneraltoarticle 804860
exec dbo.gaogeneraltoarticle 814247
exec dbo.gaogeneraltoarticle 817097
exec dbo.gaogeneraltoarticle 817102
exec dbo.gaogeneraltoarticle 819944
exec dbo.gaogeneraltoarticle 819945
exec dbo.gaogeneraltoarticle 819947
exec dbo.gaogeneraltoarticle 821967
exec dbo.gaogeneraltoarticle 821969
exec dbo.gaogeneraltoarticle 822283
exec dbo.gaogeneraltoarticle 822302
exec dbo.gaogeneraltoarticle 824934
exec dbo.gaogeneraltoarticle 824935
exec dbo.gaogeneraltoarticle 826381
exec dbo.gaogeneraltoarticle 826388
exec dbo.gaogeneraltoarticle 826664
exec dbo.gaogeneraltoarticle 828658
exec dbo.gaogeneraltoarticle 828697
exec dbo.gaogeneraltoarticle 833185
exec dbo.gaogeneraltoarticle 840731
exec dbo.gaogeneraltoarticle 840732
exec dbo.gaogeneraltoarticle 849014
exec dbo.gaogeneraltoarticle 849822
exec dbo.gaogeneraltoarticle 857634
exec dbo.gaogeneraltoarticle 858130
exec dbo.gaogeneraltoarticle 858227
exec dbo.gaogeneraltoarticle 858323
exec dbo.gaogeneraltoarticle 858331
exec dbo.gaogeneraltoarticle 858337
exec dbo.gaogeneraltoarticle 858338
exec dbo.gaogeneraltoarticle 859567
exec dbo.gaogeneraltoarticle 859665
exec dbo.gaogeneraltoarticle 827181
exec dbo.gaogeneraltoarticle 828593
exec dbo.gaogeneraltoarticle 828659
exec dbo.gaogeneraltoarticle 833273
exec dbo.gaogeneraltoarticle 838037
exec dbo.gaogeneraltoarticle 838078
exec dbo.gaogeneraltoarticle 838079
exec dbo.gaogeneraltoarticle 840727
exec dbo.gaogeneraltoarticle 840729
exec dbo.gaogeneraltoarticle 840734
exec dbo.gaogeneraltoarticle 840870
exec dbo.gaogeneraltoarticle 848054
exec dbo.gaogeneraltoarticle 849776
exec dbo.gaogeneraltoarticle 445936
exec dbo.gaogeneraltoarticle 483372
exec dbo.gaogeneraltoarticle 488059
exec dbo.gaogeneraltoarticle 488730
exec dbo.gaogeneraltoarticle 505608
exec dbo.gaogeneraltoarticle 512161
exec dbo.gaogeneraltoarticle 512200
exec dbo.gaogeneraltoarticle 512285
exec dbo.gaogeneraltoarticle 546269
exec dbo.gaogeneraltoarticle 571449
exec dbo.gaogeneraltoarticle 585070
exec dbo.gaogeneraltoarticle 633818
exec dbo.gaogeneraltoarticle 675725
exec dbo.gaogeneraltoarticle 698571
exec dbo.gaogeneraltoarticle 849777
exec dbo.gaogeneraltoarticle 857655
exec dbo.gaogeneraltoarticle 858277
exec dbo.gaogeneraltoarticle 858316
exec dbo.gaogeneraltoarticle 858325
exec dbo.gaogeneraltoarticle 858332
exec dbo.gaogeneraltoarticle 858334
exec dbo.gaogeneraltoarticle 858335
exec dbo.gaogeneraltoarticle 858342
exec dbo.gaogeneraltoarticle 859577
exec dbo.gaogeneraltoarticle 859781
exec dbo.gaogeneraltoarticle 859813
exec dbo.gaogeneraltoarticle 860215
exec dbo.gaogeneraltoarticle 869607
exec dbo.gaogeneraltoarticle 882415
exec dbo.gaogeneraltoarticle 882433
exec dbo.gaogeneraltoarticle 487805
exec dbo.gaogeneraltoarticle 488733
exec dbo.gaogeneraltoarticle 512206
exec dbo.gaogeneraltoarticle 512241
exec dbo.gaogeneraltoarticle 512279
exec dbo.gaogeneraltoarticle 512280
exec dbo.gaogeneraltoarticle 512288
exec dbo.gaogeneraltoarticle 512291
exec dbo.gaogeneraltoarticle 587661
exec dbo.gaogeneraltoarticle 684837
exec dbo.gaogeneraltoarticle 725774
exec dbo.gaogeneraltoarticle 725776
exec dbo.gaogeneraltoarticle 725781
exec dbo.gaogeneraltoarticle 882601
exec dbo.gaogeneraltoarticle 882610
exec dbo.gaogeneraltoarticle 882657
exec dbo.gaogeneraltoarticle 882658
exec dbo.gaogeneraltoarticle 898412
exec dbo.gaogeneraltoarticle 901860
exec dbo.gaogeneraltoarticle 903598
exec dbo.gaogeneraltoarticle 903599
exec dbo.gaogeneraltoarticle 903708
exec dbo.gaogeneraltoarticle 905020
exec dbo.gaogeneraltoarticle 910928
exec dbo.gaogeneraltoarticle 910943
exec dbo.gaogeneraltoarticle 910946
exec dbo.gaogeneraltoarticle 915046
exec dbo.gaogeneraltoarticle 915047
exec dbo.gaogeneraltoarticle 915357
exec dbo.gaogeneraltoarticle 915358
exec dbo.gaogeneraltoarticle 915364
exec dbo.gaogeneraltoarticle 915540
exec dbo.gaogeneraltoarticle 882656
exec dbo.gaogeneraltoarticle 903713
exec dbo.gaogeneraltoarticle 903727
exec dbo.gaogeneraltoarticle 903736
exec dbo.gaogeneraltoarticle 903755
exec dbo.gaogeneraltoarticle 910931
exec dbo.gaogeneraltoarticle 910942
exec dbo.gaogeneraltoarticle 911089
exec dbo.gaogeneraltoarticle 911090
exec dbo.gaogeneraltoarticle 912888
exec dbo.gaogeneraltoarticle 914834
exec dbo.gaogeneraltoarticle 915261
exec dbo.gaogeneraltoarticle 915360
exec dbo.gaogeneraltoarticle 915637
exec dbo.gaogeneraltoarticle 915651
exec dbo.gaogeneraltoarticle 915680
exec dbo.gaogeneraltoarticle 916037
exec dbo.gaogeneraltoarticle 916571
exec dbo.gaogeneraltoarticle 917448
exec dbo.gaogeneraltoarticle 917467
exec dbo.gaogeneraltoarticle 917549
exec dbo.gaogeneraltoarticle 923366
exec dbo.gaogeneraltoarticle 929840
exec dbo.gaogeneraltoarticle 800098
exec dbo.gaogeneraltoarticle 804561
exec dbo.gaogeneraltoarticle 804563
exec dbo.gaogeneraltoarticle 816969
exec dbo.gaogeneraltoarticle 819785
exec dbo.gaogeneraltoarticle 819877
exec dbo.gaogeneraltoarticle 819878
exec dbo.gaogeneraltoarticle 821975
exec dbo.gaogeneraltoarticle 821977
exec dbo.gaogeneraltoarticle 822285
exec dbo.gaogeneraltoarticle 822293
exec dbo.gaogeneraltoarticle 822301
exec dbo.gaogeneraltoarticle 824909
exec dbo.gaogeneraltoarticle 824933
exec dbo.gaogeneraltoarticle 826663
exec dbo.gaogeneraltoarticle 828660
exec dbo.gaogeneraltoarticle 915676
exec dbo.gaogeneraltoarticle 916009
exec dbo.gaogeneraltoarticle 916033
exec dbo.gaogeneraltoarticle 916635
exec dbo.gaogeneraltoarticle 916804
exec dbo.gaogeneraltoarticle 917563
exec dbo.gaogeneraltoarticle 923421
exec dbo.gaogeneraltoarticle 859801
exec dbo.gaogeneraltoarticle 859833
exec dbo.gaogeneraltoarticle 866185
exec dbo.gaogeneraltoarticle 870061
exec dbo.gaogeneraltoarticle 882379
exec dbo.gaogeneraltoarticle 882397
exec dbo.gaogeneraltoarticle 882446
exec dbo.gaogeneraltoarticle 882505
exec dbo.gaogeneraltoarticle 882520
exec dbo.gaogeneraltoarticle 882604
exec dbo.gaogeneraltoarticle 898807
exec dbo.gaogeneraltoarticle 903603
exec dbo.gaogeneraltoarticle 903604
exec dbo.gaogeneraltoarticle 903689
exec dbo.gaogeneraltoarticle 909794
exec dbo.gaogeneraltoarticle 909802
exec dbo.gaogeneraltoarticle 912902
exec dbo.gaogeneraltoarticle 915051
exec dbo.gaogeneraltoarticle 915359
exec dbo.gaogeneraltoarticle 725790
exec dbo.gaogeneraltoarticle 762660
exec dbo.gaogeneraltoarticle 770089
exec dbo.gaogeneraltoarticle 789639
exec dbo.gaogeneraltoarticle 804698
exec dbo.gaogeneraltoarticle 804715
exec dbo.gaogeneraltoarticle 804716
exec dbo.gaogeneraltoarticle 804756
exec dbo.gaogeneraltoarticle 804757
exec dbo.gaogeneraltoarticle 809328
exec dbo.gaogeneraltoarticle 814107
exec dbo.gaogeneraltoarticle 817098
exec dbo.gaogeneraltoarticle 819882
exec dbo.gaogeneraltoarticle 819940
exec dbo.gaogeneraltoarticle 821972
exec dbo.gaogeneraltoarticle 822281
exec dbo.gaogeneraltoarticle 822289
exec dbo.gaogeneraltoarticle 823710
exec dbo.gaogeneraltoarticle 823928
exec dbo.gaogeneraltoarticle 824184
exec dbo.gaogeneraltoarticle 826659
exec dbo.gaogeneraltoarticle 826660
exec dbo.gaogeneraltoarticle 828648
exec dbo.gaogeneraltoarticle 833186
exec dbo.gaogeneraltoarticle 833187
exec dbo.gaogeneraltoarticle 840738
exec dbo.gaogeneraltoarticle 840771
exec dbo.gaogeneraltoarticle 840772
exec dbo.gaogeneraltoarticle 840806
exec dbo.gaogeneraltoarticle 840807
exec dbo.gaogeneraltoarticle 829631
exec dbo.gaogeneraltoarticle 833272
exec dbo.gaogeneraltoarticle 838597
exec dbo.gaogeneraltoarticle 840775
exec dbo.gaogeneraltoarticle 840804
exec dbo.gaogeneraltoarticle 840869
exec dbo.gaogeneraltoarticle 849033
exec dbo.gaogeneraltoarticle 849987
exec dbo.gaogeneraltoarticle 857613
exec dbo.gaogeneraltoarticle 858324
exec dbo.gaogeneraltoarticle 858327
exec dbo.gaogeneraltoarticle 858333
exec dbo.gaogeneraltoarticle 858340
exec dbo.gaogeneraltoarticle 858341
exec dbo.gaogeneraltoarticle 859589
exec dbo.gaogeneraltoarticle 859630
exec dbo.gaogeneraltoarticle 859637
exec dbo.gaogeneraltoarticle 859988
exec dbo.gaogeneraltoarticle 860212
exec dbo.gaogeneraltoarticle 860491
exec dbo.gaogeneraltoarticle 882591
exec dbo.gaogeneraltoarticle 882607
exec dbo.gaogeneraltoarticle 882634
exec dbo.gaogeneraltoarticle 885576
exec dbo.gaogeneraltoarticle 903600
exec dbo.gaogeneraltoarticle 903866
exec dbo.gaogeneraltoarticle 909129
exec dbo.gaogeneraltoarticle 909507
exec dbo.gaogeneraltoarticle 909843
exec dbo.gaogeneraltoarticle 910929
exec dbo.gaogeneraltoarticle 910945
exec dbo.gaogeneraltoarticle 911086
exec dbo.gaogeneraltoarticle 911087
exec dbo.gaogeneraltoarticle 848368
exec dbo.gaogeneraltoarticle 859593
exec dbo.gaogeneraltoarticle 859632
exec dbo.gaogeneraltoarticle 859757
exec dbo.gaogeneraltoarticle 867905
exec dbo.gaogeneraltoarticle 869871
exec dbo.gaogeneraltoarticle 882439
exec dbo.gaogeneraltoarticle 882531
exec dbo.gaogeneraltoarticle 882631
exec dbo.gaogeneraltoarticle 884327
exec dbo.gaogeneraltoarticle 903745
exec dbo.gaogeneraltoarticle 906094
exec dbo.gaogeneraltoarticle 909711
exec dbo.gaogeneraltoarticle 909796
exec dbo.gaogeneraltoarticle 910917
exec dbo.gaogeneraltoarticle 910930
exec dbo.gaogeneraltoarticle 911091
exec dbo.gaogeneraltoarticle 911657
exec dbo.gaogeneraltoarticle 912839
exec dbo.gaogeneraltoarticle 914835
exec dbo.gaogeneraltoarticle 915654
exec dbo.gaogeneraltoarticle 915663
exec dbo.gaogeneraltoarticle 915879
exec dbo.gaogeneraltoarticle 915969
exec dbo.gaogeneraltoarticle 916020
exec dbo.gaogeneraltoarticle 916030
exec dbo.gaogeneraltoarticle 916031
exec dbo.gaogeneraltoarticle 916796
exec dbo.gaogeneraltoarticle 916855
exec dbo.gaogeneraltoarticle 917217
exec dbo.gaogeneraltoarticle 917535
exec dbo.gaogeneraltoarticle 917550
exec dbo.gaogeneraltoarticle 917551
exec dbo.gaogeneraltoarticle 917558
exec dbo.gaogeneraltoarticle 922404
exec dbo.gaogeneraltoarticle 922598
exec dbo.gaogeneraltoarticle 929827
exec dbo.gaogeneraltoarticle 725780
exec dbo.gaogeneraltoarticle 725785
exec dbo.gaogeneraltoarticle 725789
exec dbo.gaogeneraltoarticle 730874
exec dbo.gaogeneraltoarticle 762580
exec dbo.gaogeneraltoarticle 762664
exec dbo.gaogeneraltoarticle 762665
exec dbo.gaogeneraltoarticle 804738
exec dbo.gaogeneraltoarticle 804752
exec dbo.gaogeneraltoarticle 804755
exec dbo.gaogeneraltoarticle 819084
exec dbo.gaogeneraltoarticle 819879
exec dbo.gaogeneraltoarticle 819880
exec dbo.gaogeneraltoarticle 819943
exec dbo.gaogeneraltoarticle 819946
exec dbo.gaogeneraltoarticle 929833
exec dbo.gaogeneraltoarticle 821432
exec dbo.gaogeneraltoarticle 821976
exec dbo.gaogeneraltoarticle 822294
exec dbo.gaogeneraltoarticle 826389
exec dbo.gaogeneraltoarticle 826656
exec dbo.gaogeneraltoarticle 833197
exec dbo.gaogeneraltoarticle 833198
exec dbo.gaogeneraltoarticle 838080
exec dbo.gaogeneraltoarticle 838101
exec dbo.gaogeneraltoarticle 838598
exec dbo.gaogeneraltoarticle 839138
exec dbo.gaogeneraltoarticle 840735
exec dbo.gaogeneraltoarticle 843921
exec dbo.gaogeneraltoarticle 850495
exec dbo.gaogeneraltoarticle 858326
exec dbo.gaogeneraltoarticle 912325
exec dbo.gaogeneraltoarticle 912891
exec dbo.gaogeneraltoarticle 915049
exec dbo.gaogeneraltoarticle 915350
exec dbo.gaogeneraltoarticle 915356
exec dbo.gaogeneraltoarticle 915365
exec dbo.gaogeneraltoarticle 915530
exec dbo.gaogeneraltoarticle 915751
exec dbo.gaogeneraltoarticle 916015
exec dbo.gaogeneraltoarticle 916032
exec dbo.gaogeneraltoarticle 916602
exec dbo.gaogeneraltoarticle 917455
exec dbo.gaogeneraltoarticle 917712
exec dbo.gaogeneraltoarticle 922411
exec dbo.gaogeneraltoarticle 922595
exec dbo.gaogeneraltoarticle 929829
exec dbo.gaogeneraltoarticle 929830
exec dbo.gaogeneraltoarticle 929839
exec dbo.gaogeneraltoarticle 915367
exec dbo.gaogeneraltoarticle 915643
exec dbo.gaogeneraltoarticle 915644
exec dbo.gaogeneraltoarticle 915869
exec dbo.gaogeneraltoarticle 916011
exec dbo.gaogeneraltoarticle 916019
exec dbo.gaogeneraltoarticle 916021
exec dbo.gaogeneraltoarticle 916036
exec dbo.gaogeneraltoarticle 916690
exec dbo.gaogeneraltoarticle 917433
exec dbo.gaogeneraltoarticle 917457
exec dbo.gaogeneraltoarticle 917484
exec dbo.gaogeneraltoarticle 917552
exec dbo.gaogeneraltoarticle 917641
exec dbo.gaogeneraltoarticle 919144
exec dbo.gaogeneraltoarticle 922405
exec dbo.gaogeneraltoarticle 860657
exec dbo.gaogeneraltoarticle 866195
exec dbo.gaogeneraltoarticle 882315
exec dbo.gaogeneraltoarticle 882333
exec dbo.gaogeneraltoarticle 882350
exec dbo.gaogeneraltoarticle 882442
exec dbo.gaogeneraltoarticle 882624
exec dbo.gaogeneraltoarticle 898468
exec dbo.gaogeneraltoarticle 901854
exec dbo.gaogeneraltoarticle 903748
exec dbo.gaogeneraltoarticle 909708
exec dbo.gaogeneraltoarticle 909834
exec dbo.gaogeneraltoarticle 910944
exec dbo.gaogeneraltoarticle 911088
exec dbo.gaogeneraltoarticle 912690
exec dbo.gaogeneraltoarticle 912885
exec dbo.gaogeneraltoarticle 914512
exec dbo.gaogeneraltoarticle 914948
exec dbo.gaogeneraltoarticle 915048
exec dbo.gaogeneraltoarticle 915263
exec dbo.gaogeneraltoarticle 915363
exec dbo.gaogeneraltoarticle 915564
exec dbo.gaogeneraltoarticle 915642
exec dbo.gaogeneraltoarticle 915941
exec dbo.gaogeneraltoarticle 916017
exec dbo.gaogeneraltoarticle 916034
exec dbo.gaogeneraltoarticle 916035
exec dbo.gaogeneraltoarticle 916787
exec dbo.gaogeneraltoarticle 917478
exec dbo.gaogeneraltoarticle 922400
exec dbo.gaogeneraltoarticle 922401
exec dbo.gaogeneraltoarticle 922408
exec dbo.gaogeneraltoarticle 929956

exec dbo.gaogeneraltolanding 15288

exec dbo.gaoLandingtoArticle 57469
exec dbo.gaoLandingtoArticle 16362