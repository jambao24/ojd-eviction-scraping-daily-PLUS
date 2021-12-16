# ojd-eviction-scraping-daily-PLUS

Use the instructions from the main scraper to set up the scraping environment.  There are several ways to run the daily scraper but the prefered method so far has been to run the filecalled scheduler.py

scheduler.py will continue to run in the background and will automatically run run_daily_script_plus.bat at the specified time each day.

You can run run_daily_script_plus.bat anytime by double-clicking the file in file explorer or calling it in the command line.  Running this file simply activates the virtual environment and runs daily_PLUS.py - which runs through the whole process of making the postgres db, running the scrape, cleaning the data, and exporting to the shared drive folder.

If anything goes wrong, run delete_last.bat which will delete the previously created postgres db and the new shared drive folder for that day - instead of having to delete them manually.  These must be deleted before re-running the scrape for that day.
