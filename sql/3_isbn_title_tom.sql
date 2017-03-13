

DECLARE @nRecordSet int = --insert your record set ID here

--clear out the existing records from this record set (fresh start)
delete from Polaris.Polaris.BibRecordSets
where RecordSetID = @nRecordSet

create table #bibcheck 
	(bibID int,
	ISBN varchar(50))

insert into #bibcheck
select distinct bi.BibliographicRecordID,bi.ISBNString
from polaris.BibliographicISBNIndex bi (nolock)

insert into polaris.polaris.BibRecordSets(BibliographicRecordID,RecordSetID)
select distinct br.BibliographicRecordID,@nRecordSet
from #bibcheck b (nolock)
inner join Polaris.Polaris.BibliographicRecords br (nolock)
on br.BibliographicRecordID = b.bibID
inner join 
(select b.ISBN,br.SortTitle,br.PrimaryMARCTOMID
from #bibcheck b (nolock)
inner join Polaris.Polaris.BibliographicRecords br (nolock)
on br.BibliographicRecordID = b.bibID
where br.RecordStatusID = 1
and br.PrimaryMARCTOMID in (1,2,9,27,11,13)  -- adjust TOMs to your preference
and br.MARCLanguage in ('|||','eng') --adjust language to your preference
group by b.ISBN,br.SortTitle,br.PrimaryMARCTOMID
having count(*) > 1
) as d
on d.ISBN = b.ISBN and d.SortTitle = br.SortTitle and d.PrimaryMARCTOMID = br.PrimaryMARCTOMID
and br.BibliographicRecordID not in 
	(select brs.BibliographicRecordID from polaris.BibRecordSets brs (nolock)
	where RecordSetID = @nRecordSet) --if there are particular records you want to exclude, add them to record sets and add the ID here

drop table #bibcheck

--run the stored procedure to produce a result set for export
exec Polaris.SILS_Cat_UpdateDupeBibsTable @nRecordSet