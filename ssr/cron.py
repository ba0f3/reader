from apscheduler.scheduler import Scheduler
from ssr import logger
from ssr.commands import update


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