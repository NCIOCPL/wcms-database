if object_id('percReport_SecondaryURl') is not null
	drop procedure dbo.percReport_SecondaryURl 
go
create procedure dbo.percReport_SecondaryURl (@folderID int, @allfolder bit,@siteID int = 305)
as
BEGIN
	
	create table #primaryURL (contentid int, title varchar(255), primaryurl varchar(500), itempath varchar(2000),contenttype varchar(255))
	insert into #primaryURL exec percReport_PrimaryURL  @folderID, @allfolder

	select  contentid, title, primaryurl, itempath 
	, dbo.percReport_getsecondaryurl(contentid, 1) as secondaryurl1
	, dbo.percReport_getsecondaryurl(contentid, 2) as secondaryurl2
	, dbo.percReport_getsecondaryurl(contentid, 3) as secondaryurl3
	, dbo.percReport_getsecondaryurl(contentid, 4) as secondaryurl4
	from #primaryURL

END

go
