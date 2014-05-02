USE [CRD]
GO
drop PROCEDURE [dbo].[sp_FS8183_getSearchOptions]
go

/****** Object:  StoredProcedure [dbo].[sp_FS8183_getSearchOptions]    Script Date: 04/30/2014 19:08:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--Get the values to be displayed on the search criteria pop-up
CREATE PROCEDURE [dbo].[sp_FS8183_getSearchOptions]
(
	@langcode INT
) AS
BEGIN
	DECLARE @sql varchar(4000);
	DEClARE @count INT = 0;
	DECLARE @financialloopcount INT = 0;
	DECLARE @serviceloopcount INT = 0;
	DECLARE @loopcount INT = 0;
	DECLARE @financialhelp TABLE
	(
		TEMPFINANCIALID INT IDENTITY,
		FINANCIALHELPID INT,
        FINANCIALHELPDESC varchar(100)
	);
	DECLARE @otherservices1 TABLE
	(
		OTHERSERVICESID INT,
        OTHERSERVICESDESC varchar(100)
	);
	DECLARE @otherservices TABLE
	(
		TEMPOTHERID INT IDENTITY,
		OTHERSERVICESID INT,
        OTHERSERVICESDESC varchar(100)
	);
	
	DECLARE @output TABLE
	(
		TEMPID INT IDENTITY,
		FINANCIALHELPID INT,
        FINANCIALHELPDESC varchar(100),
        OTHERSERVICESID INT,
        OTHERSERVICESDESC varchar(100)
        
	)
	 
	INSERT INTO @financialhelp EXEC sp_FS8183_getFinancialHelp @langcode;
	SET @financialloopcount=@@ROWCOUNT;
	INSERT INTO @otherservices1 EXEC sp_FS8183_getOtherServices @langcode;
	insert into @otherservices select * from @otherservices1 where OTHERSERVICESID not in (1010, 1011)
	SET @serviceloopcount=@@ROWCOUNT;
	 
	--select * from @financialhelp;
	--select * from @otherservices;
	
	IF @financialloopcount > @serviceloopcount
		SET @count = @financialloopcount
	ELSE
		SET @count = @serviceloopcount
	
	SET @loopcount = 1;
	
	DECLARE @currFinId INT;
	DECLARE @currFinDesc VARCHAR(100);
	DECLARE @currOtherId INT;
	DECLARE @currOtherDesc VARCHAR(100);
	
	
	WHILE @loopcount <= @count
		BEGIN
			
			IF (@loopcount <= @financialloopcount AND @loopcount <= @serviceloopcount)
				BEGIN
					
					SELECT @currFinId=FINANCIALHELPID, @currFinDesc=FINANCIALHELPDESC FROM @financialhelp
					WHERE TEMPFINANCIALID=@loopcount;
					
					SELECT @currOtherId=OTHERSERVICESID, @currOtherDesc=OTHERSERVICESDESC FROM @otherservices
					WHERE TEMPOTHERID=@loopcount;
					
				END;
			ELSE IF (@loopcount <= @financialloopcount) --Insert only financial assistance
				BEGIN
					SELECT @currFinId=FINANCIALHELPID, @currFinDesc=FINANCIALHELPDESC FROM @financialhelp
					WHERE TEMPFINANCIALID=@loopcount;
					
					SET @currOtherId = NULL;
					SET @currOtherDesc = NULL;
					
				END;
			ELSE IF (@loopcount <= @serviceloopcount) --Insert only other services
				BEGIN
					SELECT @currOtherId=OTHERSERVICESID, @currOtherDesc=OTHERSERVICESDESC FROM @otherservices
					WHERE TEMPOTHERID=@loopcount;
					
					SET @currFinId = NULL;
					SET @currFinDesc = NULL;
					
				END;
			
			
			--insert to final temp table here
			
			INSERT INTO @output(FINANCIALHELPID, FINANCIALHELPDESC, OTHERSERVICESID, OTHERSERVICESDESC)
			VALUES (@currFinId, @currFinDesc, @currOtherId, @currOtherDesc);
			SET @loopcount = @loopcount + 1;
		END;
	
	SELECT TEMPID, FINANCIALHELPID, FINANCIALHELPDESC, OTHERSERVICESID, OTHERSERVICESDESC FROM @output;
	
END;



GO


