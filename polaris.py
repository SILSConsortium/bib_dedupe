import os
import _mssql
import csv
import argparse

def sql_connect():
	server = os.environ.get('POLARIS_PROD_DB')
	user =  os.environ.get('POLARISUSER')
	password = os.environ.get('POLARISPASS')
	#connection
	conn = _mssql.connect(server, user, password, database='Polaris')
	return conn

#only needed if SQL stored procedure doesn't run nightly
def find_sql_dupes():
	conn = sql_connect()
	try: 
		conn.execute_query('exec Polaris.SILS_CAT_IdentifyDupeBibs')
	except _mssql.MssqlDatabaseException as e:
		raise e # re-raise real error
		print(e)
	finally:
		conn.close()

#calls the stored procedure and exports duplicate information from Polaris
def get_dupes(record_set,data_file):
	conn = sql_connect()
	#q = open('sql/retrieve_dupes.sql','r')
	try:
		conn.execute_query('exec Polaris.SILS_Cat_UpdateDupeBibsTable %d',record_set)
		
		print("writing results to file")

		with open(data_file,'w') as f:
			writer = csv.writer(f)
			for row in conn:
				i = 0
				rec = []
				while i < 23:
					rec.append(row[i])
					i = i + 1
				writer.writerow(rec)

	except _mssql.MssqlDatabaseException as e:
		raise e # re-raise real error
		print(e)
	finally:
		conn.close()

#add the results to Polaris so that a report can be generated
def insert_results(file_title):
	print("updating table Polaris.SILS_duplicate_results")

	file_title = "results/" + file_title + "_duplicates.csv"
	print(file_title) 
	conn = sql_connect()
	try:
		with open(file_title,'r') as r:
			csv_file = csv.reader(r)
			for row in csv_file:
				query = '''if not exists (select * from Polaris.SILS_duplicate_results where bibID = {bID} and deleteID = {dID})
							begin 
								insert into Polaris.SILS_duplicate_results VALUES ({bID},{dID})
							end'''.format(bID = row[0], dID = row[1])
					
				conn.execute_query(query)
	except _mssql.MssqlDatabaseException as e:
		raise e # re-raise real error
		print(e)
	finally:
		conn.close()

