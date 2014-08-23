from apscheduler.scheduler import Scheduler
from reader import logger
from reader.commands import update


scheduler = Scheduler()

@scheduler.interval_schedule(minutes=30)
def update_feeds():
    logger.info("Feed updating started")
    update.feeds()

@scheduler.interval_schedule(days=1)
def update_metadata():
    logger.info("Metadata updating started")
    update.metadata()

scheduler.start()