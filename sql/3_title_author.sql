DECLARE @nRecordSet int = --insert your record set ID here

--clear out the existing records from this record set (fresh start)
delete from Polaris.Polaris.BibRecordSets
where RecordSetID = @nRecordSet

insert into polaris.polaris.BibRecordSets(BibliographicRecordID,RecordSetID)
select distinct br.BibliographicRecordID,@nRecordSet
from Polaris.Polaris.BibliographicRecords br (nolock)
inner join 
(select br.SortTitle,br.SortAuthor
from Polaris.Polaris.BibliographicRecords br (nolock)
where br.RecordStatusID = 1
and br.PrimaryMARCTOMID in (1,2,9,27,11)
and br.MARCLanguage in ('|||','eng')
group by br.SortTitle,br.SortAuthor
having count(*) > 1
) as d
on d.SortTitle = br.SortTitle and d.SortAuthor = br.SortAuthor
where br.RecordStatusID = 1
and br.PrimaryMARCTOMID in (1,2,9,27,11) -- adjust TOMs to your preference
and br.MARCLanguage in ('|||','eng') --adjust language to your preference
and br.BibliographicRecordID not in 
	(select brs.BibliographicRecordID from polaris.BibRecordSets brs (nolock)
	where RecordSetID in (@nRecordSet) --if there are particular records you want to exclude, add them to record sets and add the ID here

--run the stored procedure to produce a result set for export
exec Polaris.SILS_Cat_UpdateDupeBibsTable @nRecordSet