insert into CGVPAGEELEMENTS_CGVPAGEELEMENTS1(contentid, revisionid, backtotop)
select contentid, max(revisionid), 1 from dbo.CT_PDQDRUGINFOSUMMARY
group by contentid
