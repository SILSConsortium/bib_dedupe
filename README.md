SILS Bibliographic Record Deduplication
================

This set of SQL and Python scripts were developed by the Saskatchewan Information & Library Services Consortium (SILS) for identifying and removing duplicate records from the library catalogue.  For more information about the project, view our [presentation slides](https://docs.google.com/presentation/d/1vxH5umNJDLWWc8iglmM1Q0tEYe83Zm4pBtMtajL-5-0/edit?usp=sharing) from the Innovative Users' Group Conference.

It is intended for use with the Polaris Integrated Library System (ILS).  The T-SQL scripts are Polaris-only, but the Python scripts can be used separately from any specified ILS, provided you can manipulate your ILS's data to match the expected format.    

**DISCLAIMER:** 
*This code is provided ‘as-is’ and you use it at your own risk.   We cannot be held responsible for any damage to your ILS or cleanup charges as a result of running this code.  Make sure you understand the SQL queries you are running and test extensively on your training environment first.* 

Set up in Polaris & SQL Server:
==============
In Polaris, create an empty bibliographic record set to store the bib records you want to dedupe. 

In SQL Server Management Studio, run the T-SQL scripts in the sql directory to set up the [required tables](sql/1_create_tables.sql) and [stored procedures](sql/2_create_sp.sql). 

Set up Python
==============
We used Python 2.7, but you may be able to use Python 3.

Install Python and Pip first:
http://docs.python-guide.org/en/latest/starting/installation/

After installing Python and Pip, go to the bib_dedupe folder and use pip to instal the necessary packages to run the scripts.

    pip install -r requirements

There is a sample data extract from 11665 bibliographic records.  Test your environment by running the deduplication script on the sample data:

    python deduplicate.py

If everything runs successfully, you will have 4 csv files in the [results](results) directory.  Clear those files out prior to running the script on your ILS data.

Step 1: Extracting data from Polaris
=======================

Use one of the following SQL scripts to target a section of your catalog for deduping based on exact matching fields.  Set the @nRecordSetID variable to the record set you created during setup.
* [ISBN match only](sql/3_isbn_only.sql)
* [ISBN/Exact Title match](sql/3_isbn_title.sql) 
* [ISBN/Exact Title/Type of Material(TOM)](sql/3_isbn_title_tom.sql)
* [ISBN/Type of Material(TOM)](sql/3_isbn_tom.sql)
* [Exact Title/Exact Author](sql/3_title_author.sql)
* [Exact Title/Exact Author/Type of Material(TOM)](sql/3_title_author_tom.sql)

Export the results of this query to a csv file.

Step 2: Configuring and running the Python script
=======================
You can use the [config.toml](config.toml) file to set input and output options and set your matching criteria.  You can choose which fields you want to compare, using which algorithm (exact, similarity ratio, etc).  If you use a fuzzy matching algorithm, it also allows you to set cutoff percentage rating (e.g. titles with > 80% similarity are considered a match).

If you want to test the sensitivity of your fuzzy match settings, try running the sample script:

    python sample.py

More information about the fuzzywuzzy library can be found at: http://chairnerd.seatgeek.com/fuzzywuzzy-fuzzy-string-matching-in-python/

After setting your configuration settings (including pointing the script to the location of your data file) run it again:

    python deduplicate.py

After the script has run, go to your [results](results) folder to see the output.

Step 3: Importing the data into SQL Server and merging duplicate records
===========

Copy your duplicate file (ending in 'duplicates.csv') and copy it to your SQL server C: drive. In SQL Server Management Studio, run the [sql/4_import_results.sql](sql/4_import_results.sql) query to load the file.

After it is loaded, run the stored procedure to merge the bibs.  Use the Organization ID, User ID, and Workstation ID you want associated with the transactions.

    exec Polaris.SILS_Cat_MergeBibs <orgid>,<userid>,<workstationid>

By default, running this procedure will merge 100 records at a time.  You have to alter the stored procedure to change this value.

