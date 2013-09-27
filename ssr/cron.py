from apscheduler.scheduler import Scheduler

schedule = Scheduler()
schedule.start()


@sched.interval_schedule(hours=3)
def some_job():
    print "Decorated job"