import os
import psycopg2
from psycopg2 import sql
from datetime import date, timedelta
import shutil
import subprocess

today = date.today() # - timedelta(days=1)

# delete directory

dir_path = "C:\\Shared drives\\DAILY_SCRAPE_OJD\\Daily_Cases_" + today.strftime("%m_%d_%Y") # + "_PLUS"

try:
    shutil.rmtree(dir_path)
except OSError as e:
    print("Error: %s : %s" % (dir_path, e.strerror))


# delete postgres database
con = psycopg2.connect(
   database="postgres", user='postgres', password='admin', host='127.0.0.1', port= '5432'
)

con.autocommit = True

cur = con.cursor()

name_Database = "daily_" + today.strftime("%m_%d_%Y") # + "_PLUS"

cur.execute("DROP DATABASE " + name_Database + ";")

#Closing the connection
con.close()