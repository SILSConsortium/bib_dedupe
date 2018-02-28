USE [Polaris]
GO

/****** Object:  StoredProcedure [Polaris].[SILS_Cat_IdentifyDupeBibs]    Script Date: 27/02/2018 5:31:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Dale Storie
-- Create date: 2016-05-19
-- Description:	This procedure creates record sets of bibs that share ISBNs,UPCs,and Titles
-- =============================================
ALTER PROCEDURE [Polaris].[SILS_Cat_IdentifyDupeBibs]

AS
BEGIN

	SET NOCOUNT ON;

--choose recordset to add to
DECLARE @recordsetISBN int = 22531
DECLARE @recordsetUPC int = 30194
DECLARE @recordsetTitle int = 22534

--empty out the sets for a fresh start
delete from Polaris.Polaris.BibRecordSets
where RecordSetID in (@recordsetISBN,@recordsetUPC,@recordsetTitle)

--add records with a duplicate isbn to record set 22531
CREATE table #bibcheckISBN 
	(bibID int,
	ISBN varchar(50))

insert into #bibcheckISBN
select distinct bi.BibliographicRecordID,bi.ISBNString
from polaris.BibliographicISBNIndex bi (nolock)

insert into polaris.polaris.BibRecordSets(BibliographicRecordID,RecordSetID)
select distinct br.BibliographicRecordID,@recordsetISBN
from #bibcheckISBN b (nolock)
inner join Polaris.Polaris.BibliographicRecords br (nolock)
on br.BibliographicRecordID = b.bibID
inner join 
(select b.ISBN,br.SortTitle,br.PrimaryMARCTOMID
from #bibcheckISBN b (nolock)
inner join Polaris.Polaris.BibliographicRecords br (nolock)
on br.BibliographicRecordID = b.bibID
where br.RecordStatusID = 1
--if you want to dedupe electronic, reverse this phrase ('in' rather than 'not in')
and br.PrimaryMARCTOMID not in (50,49,48,41,38,36,6)
and br.MARCLanguage in ('|||','eng','')
--CELA and NNELS are not deduped
and br.MARCMedium not like ('RESTRICTED%')
group by b.ISBN,br.SortTitle,br.PrimaryMARCTOMID
having count(*) > 1
) as d
on d.ISBN = b.ISBN
and br.BibliographicRecordID not in 
	(select brs.BibliographicRecordID from polaris.BibRecordSets brs (nolock)
	where RecordSetID = @recordsetISBN)

select count(*) from polaris.BibRecordSets where RecordSetID = @recordsetISBN

drop table #bibcheckISBN

--add records with duplicates UPCs
create table #bibcheckUPC 
	(bibID int,
	UPC varchar(50))

insert into #bibcheckUPC
select distinct bi.BibliographicRecordID,bi.UPCNumber
from polaris.BibliographicUPCIndex bi (nolock)

insert into polaris.polaris.BibRecordSets(BibliographicRecordID,RecordSetID)
select distinct br.BibliographicRecordID,@recordsetUPC
from #bibcheckUPC b (nolock)
inner join Polaris.Polaris.BibliographicRecords br (nolock)
on br.BibliographicRecordID = b.bibID
inner join 
(select b.UPC,br.SortTitle,br.PrimaryMARCTOMID
from #bibcheckUPC b (nolock)
inner join Polaris.Polaris.BibliographicRecords br (nolock)
on br.BibliographicRecordID = b.bibID
where br.RecordStatusID = 1
--if you want to dedupe electronic, reverse this phrase ('in' rather than 'not in')
and br.PrimaryMARCTOMID not in (50,49,48,41,38,36,6)
and br.MARCLanguage in ('|||','eng','')
--CELA and NNELS are not deduped
and br.MARCMedium not like ('RESTRICTED%')
group by b.UPC,br.SortTitle,br.PrimaryMARCTOMID
having count(*) > 1
) as d
on d.UPC = b.UPC
and br.BibliographicRecordID not in 
	(select brs.BibliographicRecordID from polaris.BibRecordSets brs (nolock)
	where RecordSetID = @recordsetUPC)

select count(*) from polaris.BibRecordSets where RecordSetID = @recordsetUPC

drop table #bibcheckUPC

--add records with Title dupes
insert into polaris.polaris.BibRecordSets(BibliographicRecordID,RecordSetID)
select distinct br.BibliographicRecordID,@recordsetTitle
from Polaris.Polaris.BibliographicRecords br (nolock)
inner join 
(select br.SortTitle,br.SortAuthor,br.PrimaryMARCTOMID
from Polaris.Polaris.BibliographicRecords br (nolock)
where br.RecordStatusID = 1
--if you want to dedupe electronic, reverse this phrase ('in' rather than 'not in') -make sure you change this in line 128 below
and br.PrimaryMARCTOMID not in (50,49,48,41,38,36,6)
and br.MARCLanguage in ('|||','eng','')
--CELA and NNELS are not deduped
and br.MARCMedium not like ('RESTRICTED%')
group by br.SortTitle,br.SortAuthor,br.PrimaryMARCTOMID
having count(*) > 1
) as d
on d.SortTitle = br.SortTitle --and d.SortAuthor = br.SortAuthor --and d.PrimaryMARCTOMID = br.PrimaryMARCTOMID
where br.RecordStatusID = 1 
--electronic flip here too 
and br.PrimaryMARCTOMID not in (50,49,48,41,38,36,6)
and br.MARCLanguage in ('|||','eng','')
--CELA and NNELS are not deduped
and br.MARCMedium not like ('RESTRICTED%')
and br.BibliographicRecordID not in 
	(select brs.BibliographicRecordID from polaris.BibRecordSets brs (nolock)
	where RecordSetID in (@recordsetTitle,40437,40440)) --these two record sets are non-fiction titles that should probably not be deduped

select count(*) from polaris.BibRecordSets where RecordSetID = @recordsetTitle

END 

GO