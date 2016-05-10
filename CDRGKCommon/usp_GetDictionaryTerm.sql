IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetDictionaryTerm]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GetDictionaryTerm]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Retrieves a specific term

CREATE PROCEDURE [dbo].[usp_GetDictionaryTerm]
	@TermID int,	-- Identifier for the term (not just a row)
	@Dictionary nvarchar(10),
	@Language nvarchar(20),
	@Audience nvarchar(25),
	@ApiVers nvarchar(10) -- What version of the API (there may be multiple).

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @i int 

	declare @termSort TABLE(
     Dictionary nvarchar(10) NOT NULL,
     Audience nvarchar(25) NOT NULL,
     Cycle int NOT NULL
	)
 
	 INSERT INTO @termSort VALUES 
	  ('Term', 'Patient', 1)
	 ,('Term', 'HealthProfessional', 2)
	 ,('NotSet', 'Patient', 3)
	 ,('NotSet', 'HealthProfessional', 4)
	 ,('Genetic', 'Patient', 5)
	 ,('Genetic', 'HealthProfessional', 6)
 

 	IF exists 
		(select TermID, TermName, Dictionary, Language, Audience, ApiVers, object
		from Dictionary
		where TermID = @TermID
		  and Dictionary = @Dictionary
		  and Language = @Language
		  and Audience = @Audience
		  and ApiVers = @ApiVers)
			  select TermID, TermName, Dictionary, Language, Audience, ApiVers, object
					from Dictionary
					where TermID = @TermID
					  and Dictionary = @Dictionary
					  and Language = @Language
					  and Audience = @Audience
					  and ApiVers = @ApiVers

	  ELSE
			BEGIN
				select @i = t.Cycle from @termSort t where t.dictionary = @dictionary and t.Audience = @Audience
				
				if exists
				(
				select TermID, TermName, d.Dictionary, Language, d.Audience, ApiVers, object
				from Dictionary d inner join @termSort t on d.Dictionary = t.Dictionary and d.Audience = t.Audience
					where TermID = @TermID
						and Language = @Language
						and ApiVers = @ApiVers
						and t.cycle >= @i 
					 )
					 
					 select top 1 TermID, TermName, d.Dictionary, Language, d.Audience, ApiVers, object
							from Dictionary d inner join @termSort t on d.Dictionary = t.Dictionary and d.Audience = t.Audience
							where TermID = @TermID
								and Language = @Language
								and ApiVers = @ApiVers
								and t.cycle > =@i 
							 order by t.cycle 
				ELSE
						select top 1 TermID, TermName, d.Dictionary, Language, d.Audience, ApiVers, object
							from Dictionary d inner join @termSort t on d.Dictionary = t.Dictionary and d.Audience = t.Audience
							where TermID = @TermID
								and Language = @Language
								and ApiVers = @ApiVers
								order by cycle 
						 

			END 
	
END
GO


GO
GRANT EXECUTE ON [dbo].[usp_GetDictionaryTerm] TO [webSiteUser_role]
GO
