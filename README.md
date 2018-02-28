SILS Bibliographic Record Deduplication
================

**NOTE**
*We recently updated our code.  It is now using Python 3 and is designed to extract data directly from SQL Server using pymssql.*  

The older commit is available here for download:
https://github.com/SILSConsortium/bib_dedupe/tree/db56b82df06b6d4ef40616baa0c916752245c39d

This set of SQL and Python scripts were developed by the Saskatchewan Information & Library Services Consortium (SILS) for identifying and removing duplicate records from the library catalogue.  For more information about the project, view our [presentation slides](https://docs.google.com/presentation/d/1vxH5umNJDLWWc8iglmM1Q0tEYe83Zm4pBtMtajL-5-0/edit?usp=sharing) from the Innovative Users' Group Conference.

It is intended for use with the Polaris Integrated Library System (ILS).  The T-SQL scripts are Polaris-only, but the Python scripts can be used separately from any specified ILS, provided you can manipulate your ILS's data to match the expected format.    

**DISCLAIMER:** 
*This code is provided ‘as-is’ and you use it at your own risk.   We cannot be held responsible for any damage to your ILS or cleanup charges as a result of running this code.  Make sure you understand the SQL queries you are running and test extensively on your training environment first.* 

Set up in Polaris & SQL Server:
==============

To decrease overall processing time, we use SQL server to identify duplicate sets based on exact ISBN,UPC, or Title first.  This data is then retrieved by a Python script which does a further duplicate detection stage using fuzzy string comparison.

In SQL Server Management Studio, run the T-SQL scripts in the sql directory to set up the [required tables](sql/1_create_tables.sql) and [stored procedures](sql/2_create_sp.sql). 

In Polaris client, create three empty bibliographic record sets to store the bib records you want to dedupe.  Name them according to the primary match field for each. 
  * ISBN
  * UPC
  * Title

Modify the [third and final T-SQL script](sql/3_create_exact_match_sp.sql) and set it to use the record set IDs that you created.  Execute the script to create this stored procedure.  **Note** You will need to execute this procedure prior to running the python script.  

Set up Python 3
==============

Install Python and Pip first:
http://docs.python-guide.org/en/latest/starting/installation/

After installing Python and Pip, go to the bib_dedupe folder and use pip to install the necessary packages to run the scripts.

    pip install -r requirements

There is a sample data extract from 11665 bibliographic records.  Test your environment by running the deduplication script on the sample data:

    python deduplicate.py -s

If everything runs successfully, you will have 3 csv files in the [results](results) directory.  Clear those files out prior to running the script on your ILS data.

Step 2: Configuring and running the Python script on live data
=======================

You can use the [config.toml](config.toml) file to set which Polaris record sets to use (created in Part 1) and choose your matching criteria.  You can choose which fields you want to compare, using which matching algorithm (exact, similarity ratio, etc).  If you use a fuzzywuzzy algorithm, it also allows you to set cutoff percentage rating (e.g. titles with > 80% similarity are considered a match).

If you want to test the sensitivity of your fuzzy match settings, try running the sample script:

    python sample.py

More information about the fuzzywuzzy library can be found at: http://chairnerd.seatgeek.com/fuzzywuzzy-fuzzy-string-matching-in-python/

After you choose your match settings, run the python script with a command-line argument to process the pre-collected Polaris record set (options are isbn,upc,title,sample).  The default is isbn if no argument is given.

    python deduplicate.py -u

After the script has run, go to your [results](results) folder to see the output.

Step 3: Addressing duplicate records in SQL Server
===========

After running the python script, the results will be added to a table called SILS_duplicate_results.  You can write SSRS reports against that data.  

You can, optionally, run another stored procedure to merge the bibs, if you are comfortable with doing so.  Use the Organization ID, User ID, and Workstation ID you want associated with the transactions.

    exec Polaris.SILS_Cat_MergeBibs <orgid>,<userid>,<workstationid>

By default, running this procedure will merge 100 records at a time.  You have to alter the stored procedure to change this value.

For SILS, if you want to avoid deduping records again, put them in either 40437 or 40440 and they will be excluded from the report.

To dedupe electronic resources, NNELS, CELA and video games, adjust the stored procedure [Polaris].[SILS_Cat_IdentifyDupeBibs].  There are comments in that procedure on how to switch to electronic TOMs.  

