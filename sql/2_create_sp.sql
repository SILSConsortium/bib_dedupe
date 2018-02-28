--creates three stored procedures
--1) SILS_Cat_UpdateDupeBibsTable (for assembling record details for python processing)
--2) SILS_Cat_WriteBibIDtoItem (For items copied to a new bib, the deleted bib record ID is added the Physical Condition field in the item record)
--3) SILS_Cat_Merge_Bibs (Uses Polaris stored procedures to copy items and holds from one record to another and delete the leftover bib record)

--CAUTION: 2 & 3 write to the database.  Proceed carefully.


--first procedure
USE [Polaris]
GO

/****** Object:  StoredProcedure [Polaris].[SILS_Cat_UpdateDupeBibsTable]    Script Date: 27/02/2018 4:44:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
CREATE PROCEDURE [Polaris].[SILS_Cat_UpdateDupeBibsTable]
	@recordset int 
AS
BEGIN

	SET NOCOUNT ON;
	--22531 ISBN
	--30194 UPC
	--22534 TitleAuthor

TRUNCATE TABLE Polaris.SILS_duplicates

insert into Polaris.SILS_duplicates(bibID,Title,Author,PrimaryTOM,MARCMedium,PubDate1)
select distinct br.BibliographicRecordID,br.SortTitle,br.SortAuthor,br.PrimaryMARCTOMID,br.MARCMedium,br.MARCPubDateOne 
from polaris.Polaris.BibliographicRecords br (nolock)
inner join polaris.polaris.bibrecordsets brs (nolock)
on br.BibliographicRecordID = brs.BibliographicRecordID
where brs.RecordSetID = @recordset

update Polaris.Polaris.SILS_duplicates 
set Tag008 = (select top 1 REPLACE(bsf.Data, ' ', '')
from polaris.BibliographicTags bt (nolock)
inner join polaris.BibRecordSets brs (nolock)
on bt.BibliographicRecordID = brs.BibliographicRecordID
inner join polaris.BibliographicSubfields bsf (nolock)
on bt.BibliographicTagID = bsf.BibliographicTagID
where bt.EffectiveTagNumber = 8
and brs.RecordSetID = @recordset
and BibID = bt.BibliographicRecordID)

update Polaris.Polaris.SILS_duplicates 
set Tag24x = (select count(bt.EffectiveTagNumber) from polaris.BibliographicTags bt (nolock)
inner join polaris.BibRecordSets brs (nolock)
on bt.BibliographicRecordID = brs.BibliographicRecordID
where bt.EffectiveTagNumber between 240 and 249
and brs.RecordSetID = @recordset
and BibID = bt.BibliographicRecordID
group by bt.BibliographicRecordID)

update Polaris.Polaris.SILS_duplicates 
set Tag3xx = 
(select count(bt.EffectiveTagNumber) from polaris.BibliographicTags bt (nolock)
inner join polaris.BibRecordSets brs (nolock)
on bt.BibliographicRecordID = brs.BibliographicRecordID
where bt.EffectiveTagNumber between 300 and 380
and brs.RecordSetID = @recordset
and BibID = bt.BibliographicRecordID
group by bt.BibliographicRecordID)

update Polaris.Polaris.SILS_duplicates 
set Tag5xx = 
(select count(bt.EffectiveTagNumber) from polaris.BibliographicTags bt (nolock)
inner join polaris.BibRecordSets brs (nolock)
on bt.BibliographicRecordID = brs.BibliographicRecordID
where bt.EffectiveTagNumber between 500 and 589
and brs.RecordSetID = @recordset
and BibID = bt.BibliographicRecordID
group by bt.BibliographicRecordID)

update Polaris.Polaris.SILS_duplicates 
set Tag6xx = 
(select count(bt.EffectiveTagNumber) from polaris.BibliographicTags bt (nolock)
inner join polaris.BibRecordSets brs (nolock)
on bt.BibliographicRecordID = brs.BibliographicRecordID
where bt.EffectiveTagNumber between 600 and 699
and brs.RecordSetID = @recordset
and BibID = bt.BibliographicRecordID
group by bt.BibliographicRecordID)

update Polaris.Polaris.SILS_duplicates 
set Tag7xx =
(select count(bt.EffectiveTagNumber) from polaris.BibliographicTags bt (nolock)
inner join polaris.BibRecordSets brs (nolock)
on bt.BibliographicRecordID = brs.BibliographicRecordID
where bt.EffectiveTagNumber between 700 and 799
and brs.RecordSetID = @recordset
and BibID = bt.BibliographicRecordID
group by bt.BibliographicRecordID)

update Polaris.Polaris.SILS_duplicates 
set TagMisc =
(select count(bt.EffectiveTagNumber) from polaris.BibliographicTags bt (nolock)
inner join polaris.BibRecordSets brs (nolock)
on bt.BibliographicRecordID = brs.BibliographicRecordID
where bt.EffectiveTagNumber in (440,490,800,830)
and brs.RecordSetID = @recordset
and BibID = bt.BibliographicRecordID
group by bt.BibliographicRecordID)

update Polaris.Polaris.SILS_duplicates 
set Tag856 =
(select count(bt.EffectiveTagNumber) from polaris.BibliographicTags bt (nolock)
inner join polaris.BibRecordSets brs (nolock)
on bt.BibliographicRecordID = brs.BibliographicRecordID
where bt.EffectiveTagNumber = 856
and brs.RecordSetID = @recordset
and BibID = bt.BibliographicRecordID
group by bt.BibliographicRecordID)

update Polaris.Polaris.SILS_duplicates 
set LinkedItems = 
(select count(ItemRecordID)
from polaris.BibliographicRecords br (nolock)
inner join polaris.BibRecordSets brs (nolock)
on br.BibliographicRecordID = brs.BibliographicRecordID
left join Polaris.Polaris.CircItemRecords cir (nolock)
on cir.AssociatedBibRecordID = br.BibliographicRecordID
where cir.RecordStatusID = 1
and brs.RecordSetID = @recordset
and BibID = br.BibliographicRecordID
group by br.BibliographicRecordID)

update Polaris.Polaris.SILS_duplicates 
set Tag300a = 
(select min(bsf.Data) from Polaris.BibliographicTags bt (nolock)
inner join polaris.BibRecordSets brs (nolock)
on bt.BibliographicRecordID = brs.BibliographicRecordID
inner join polaris.polaris.BibliographicSubfields bsf (nolock)
on bt.BibliographicTagID = bsf.BibliographicTagID
where bt.EffectiveTagNumber = 300
and bsf.Subfield = 'a'
and brs.RecordSetID = @recordset
and BibID = bt.BibliographicRecordID
group by bt.BibliographicRecordID)

update Polaris.Polaris.SILS_duplicates 
set Tag300b = 
(select min(bsf.Data) from Polaris.BibliographicTags bt (nolock)
inner join polaris.BibRecordSets brs (nolock)
on bt.BibliographicRecordID = brs.BibliographicRecordID
inner join polaris.polaris.BibliographicSubfields bsf (nolock)
on bt.BibliographicTagID = bsf.BibliographicTagID
where bt.EffectiveTagNumber = 300
and bsf.Subfield = 'b'
and brs.RecordSetID = @recordset
and BibID = bt.BibliographicRecordID)

update Polaris.Polaris.SILS_duplicates 
set Tag300c = 
(select min(bsf.Data) from Polaris.BibliographicTags bt (nolock)
inner join polaris.BibRecordSets brs (nolock)
on bt.BibliographicRecordID = brs.BibliographicRecordID
inner join polaris.polaris.BibliographicSubfields bsf (nolock)
on bt.BibliographicTagID = bsf.BibliographicTagID
where bt.EffectiveTagNumber = 300
and bsf.Subfield = 'c'
and brs.RecordSetID = @recordset)

update Polaris.Polaris.SILS_duplicates 
set PubDate260 = 
(select min(bsf.Data) from Polaris.BibliographicTags bt (nolock)
inner join polaris.BibRecordSets brs (nolock)
on bt.BibliographicRecordID = brs.BibliographicRecordID
inner join polaris.polaris.BibliographicSubfields bsf (nolock)
on bt.BibliographicTagID = bsf.BibliographicTagID
where bt.EffectiveTagNumber = 260
and bsf.Subfield = 'c'
and brs.RecordSetID = @recordset
and BibID = bt.BibliographicRecordID)

update Polaris.Polaris.SILS_duplicates 
set Tag490 = 
(select min(bsf.Data) from Polaris.BibliographicTags bt (nolock)
inner join polaris.BibRecordSets brs (nolock)
on bt.BibliographicRecordID = brs.BibliographicRecordID
inner join polaris.polaris.BibliographicSubfields bsf (nolock)
on bt.BibliographicTagID = bsf.BibliographicTagID
where bt.EffectiveTagNumber = 490
and brs.RecordSetID = @recordset
and BibID = bt.BibliographicRecordID)

update Polaris.Polaris.SILS_duplicates 
set Tag245c = 
(select min(bsf.Data) from Polaris.BibliographicTags bt (nolock)
inner join polaris.BibRecordSets brs (nolock)
on bt.BibliographicRecordID = brs.BibliographicRecordID
inner join polaris.polaris.BibliographicSubfields bsf (nolock)
on bt.BibliographicTagID = bsf.BibliographicTagID
where bt.EffectiveTagNumber = 245
and bsf.Subfield = 'c'
and brs.RecordSetID = @recordset
and BibID = bt.BibliographicRecordID)

update Polaris.Polaris.SILS_duplicates 
set Tag245n = 
(select min(bsf.Data) from Polaris.BibliographicTags bt (nolock)
inner join polaris.BibRecordSets brs (nolock)
on bt.BibliographicRecordID = brs.BibliographicRecordID
inner join polaris.polaris.BibliographicSubfields bsf (nolock)
on bt.BibliographicTagID = bsf.BibliographicTagID
where bt.EffectiveTagNumber = 245
and bsf.Subfield = 'n'
and brs.RecordSetID = @recordset
and BibID = bt.BibliographicRecordID)

update Polaris.Polaris.SILS_duplicates 
set Tag245b = 
(select min(bsf.Data) from Polaris.BibliographicTags bt (nolock)
inner join polaris.BibRecordSets brs (nolock)
on bt.BibliographicRecordID = brs.BibliographicRecordID
inner join polaris.polaris.BibliographicSubfields bsf (nolock)
on bt.BibliographicTagID = bsf.BibliographicTagID
where bt.EffectiveTagNumber = 245
and bsf.Subfield = 'b'
and brs.RecordSetID = @recordset
and BibID = bt.BibliographicRecordID)

update Polaris.Polaris.SILS_duplicates 
set Tag245p = 
(select min(bsf.Data) from Polaris.BibliographicTags bt (nolock)
inner join polaris.BibRecordSets brs (nolock)
on bt.BibliographicRecordID = brs.BibliographicRecordID
inner join polaris.polaris.BibliographicSubfields bsf (nolock)
on bt.BibliographicTagID = bsf.BibliographicTagID
where bt.EffectiveTagNumber = 245
and bsf.Subfield = 'p'
and brs.RecordSetID = @recordset
and BibID = bt.BibliographicRecordID)

select bibID, 
	 COALESCE(Title,'') as Title,
	 COALESCE(Author,'none') as Author,
	 COALESCE(PrimaryTOM,0) as TOM, 
	 COALESCE(MARCMedium,'BOOK') as Medium, 
	 COALESCE(PubDate1,'') as PubDate1, 
	 COALESCE(Tag24x,0) as count24x,
	 COALESCE(Tag3xx,0) as count3xx,
	 COALESCE(Tag5xx,0) as count5xx,
	 COALESCE(Tag6xx,0) as count6xx,
	 COALESCE(Tag7xx,0) as count7xx,
	 COALESCE(Tag856,0) as count856,
	 COALESCE(TagMisc,0) as countMisc,
	 (COALESCE(LEN(Tag300a),0) + COALESCE(LEN(Tag300b),0) + COALESCE(LEN(Tag300c),0)) as Tag300,
	 COALESCE(LinkedItems,0) as LinkedItems,
	 CASE
		WHEN @recordset = <insert your UPC record set here> then u.UPCNumber
		ELSE bi.ISBNString
	 END as sn,
	 COALESCE(Tag008,'') as Tag008,
	 COALESCE(PubDate260,'') as Pubdate260,
	 '"' + COALESCE(Tag490,'') + '"' as Tag490,
	 '"' + COALESCE(REPLACE(Tag245c,'"',''),'') + '"' as Tag245c,
	 '"' + COALESCE(REPLACE(Tag245n,'"',''),'') + '"' as Tag245n,
	 '"' + COALESCE(REPLACE(Tag245b,'"',''),'') + '"' as Tag245b,
	 '"' + COALESCE(REPLACE(Tag245p,'"',''),'') + '"' as Tag245p
FROM Polaris.Polaris.SILS_duplicates
left join Polaris.Polaris.BibliographicISBNIndex bi (nolock)
on BibID = bi.BibliographicRecordID
left join Polaris.Polaris.BibliographicUPCIndex u (nolock)
on BibID = u.BibliographicRecordID

END 


GO


--second procedure

USE [Polaris]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Polaris].[SILS_Cat_WriteBibIDtoItem]
	@nDeletedID int
AS
BEGIN
	SET NOCOUNT ON;

update 
  Polaris.ItemRecordDetails
set PhysicalCondition = 
	( CASE  
         WHEN ird.PhysicalCondition is null THEN ('SILS deduplication: Merged from BibID:' + convert(varchar(55),@nDeletedID)) 
         ELSE convert(varchar(max),ird.PhysicalCondition) + ' SILS deduplication: Merged from BibID ' + convert(varchar(55),@nDeletedID)
       END  
    ) 
FROM Polaris.ItemRecordDetails ird  
inner join Polaris.CircItemRecords cir
on cir.ItemRecordID = ird.ItemRecordID
where cir.AssociatedBibRecordID = @nDeletedID

END 



GO


--third procedure

USE [Polaris]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Polaris].[SILS_Cat_MergeBibs]
	@nOrganizationID int,
	@nUserID int,
	@nWorkstationID int
AS
BEGIN
	SET NOCOUNT ON;

DECLARE @nBibID int
DECLARE @nDeletedID int

DECLARE merge_cur CURSOR FOR 

--records to delete.  --set to 100 adjust to preference

select top 100 BibID,DeletedID,@nOrganizationID,@nUserID,@nWorkstationID
from Polaris.SILS_duplicate_results dup (nolock)
inner join polaris.BibliographicRecords br1 (nolock)
on dup.BibID = br1.BibliographicRecordID
inner join polaris.BibliographicRecords br2 (nolock)
on dup.DeletedID = br2.BibliographicRecordID
where br1.RecordStatusID = 1
and br2.RecordStatusID = 1
and dup.BibID not in 
(select ObjectID from polaris.ObjectLocks where ObjectTypeID = 2)
and dup.DeletedID not in 
(select ObjectID from polaris.ObjectLocks where ObjectTypeID = 2)
group by bibid,deletedid
order by BibID

--begin cursor
OPEN merge_cur

FETCH NEXT FROM merge_cur INTO @nBibID,@nDeletedID,@nOrganizationID,@nUserID,@nWorkstationID

WHILE @@FETCH_STATUS = 0 BEGIN

	--write deleted bib number to item record in case we need to reinstate
	exec Polaris.SILS_Cat_WriteBibIDtoItem @nDeletedID

	--stored procedure parameters to SILS Online branch (255),Dale's Computer (1612), and a.dstorie (1896)
    EXEC [Polaris].[Cat_ReassignBibRecordLinks] @nBibID,@nDeletedID,@nOrganizationID,@nUserID,@nWorkstationID
	EXEC [Polaris].[Cat_DeleteBibRecordProcessing] @nDeletedID,@nOrganizationID,@nUserID,@nWorkstationID,null,null,0,1,null

    FETCH NEXT FROM merge_cur INTO @nBibID,@nDeletedID,@nOrganizationID,@nUserID,@nWorkstationID

END

CLOSE merge_cur    
DEALLOCATE merge_cur

END

GO



