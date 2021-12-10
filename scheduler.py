import schedule
import time
import subprocess

def job():
    subprocess.call([r'run_daily_script_plus.bat'])

schedule.every().day.at('11:50').do(job)

while True:
    schedule.run_pending()
    time.sleep(1)
