import os
import psycopg2
from psycopg2 import sql
from datetime import date, timedelta
import subprocess

today = date.today() # - timedelta(days=1)

# Manual Mode
# today = datetime(2021, 8, 29)

# create postgres database

con = psycopg2.connect(
   database="postgres", user='postgres', password='admin', host='127.0.0.1', port= '5432'
)

con.autocommit = True

cur = con.cursor()

name_Database = "daily_" + today.strftime("%m_%d_%Y")

cur.execute("CREATE DATABASE "+name_Database+";")

#Closing the connection
con.close()

#print("working directory: " + os.getcwd())
#os.chdir(os.getcwd() + "\\ojd_evictions")

# call the crawl
cmd = "scrapy"
arg1 = "crawl"
arg2 = "ojd_evictions_PLUS"
subprocess.call([cmd, arg1, arg2], shell=True)

#os.system("scrapy crawl ojd_evictions")

#os.makedirs("G:\\My Drive\\DAILY_SCRAPE_OJD\\Daily_Cases_" + today.strftime("%m_%d_%Y"))
#os.makedirs("G:\\Shared drives\\DAILY_SCRAPE_OJD\\Daily_Cases_" + today.strftime("%m_%d_%Y") + "_PLUS")

# run r script to get tables and write to csv
command = "C:\\Program Files\\R\\R-4.0.5\\bin\\Rscript.exe"
path2script = "C:\\Users\\jdmac\\PycharmProjects\\ojd-eviction-scraping-daily-PLUS\\data_cleaning_PLUS.R"

subprocess.call([command, path2script], shell=True)

# get file extenstions
cmd = "C:\\trid_w32\\trid.exe"
path2 = "G:\\Shared drives\\DAILY_SCRAPE_OJD\\Daily_Cases_" + today.strftime("%m_%d_%Y") + "\\Court_Documents_" + today.strftime("%m_%d_%Y") + "\\*"
arg1 = "-ae"

subprocess.call([cmd, path2, arg1], shell=True)

