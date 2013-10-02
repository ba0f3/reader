from apscheduler.scheduler import Scheduler
from ssr import logger
from ssr.updater import Updater


scheduler = Scheduler()

@scheduler.interval_schedule(minutes=30)
def update_feeds():
    logger.info("Feed updating started")
    Updater.feeds()

@scheduler.interval_schedule(days=1)
def update_metadata():
    logger.info("Metadata updating started")
    Updater.metadata()

scheduler.start()