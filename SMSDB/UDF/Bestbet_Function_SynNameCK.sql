IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Bestbet_Function_SynNameCK]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Bestbet_Function_SynNameCK]
GO


create function dbo.Bestbet_Function_SynNameCK 
(@SynonymID uniqueidentifier, @synName varchar(255))
returns bit
as

begin
	return
	( select case when @synName = c.catName then 0 else 1 end
		from dbo.bestbetSynonym s 
		inner join dbo.bestbetcategory c on s.categoryid = c.categoryid
		where synonymID =@SynonymID 
	)
	
end

GO
