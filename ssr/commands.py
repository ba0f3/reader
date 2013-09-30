from flask.ext.script import Manager, Command
from ssr import db
from ssr.models import *
import feedparser
from dateutil import parser
from ssr import app
from ssr.updater import Updater;
import uuid;

DevelCommand = Manager(usage="Useful commands for development")

@DevelCommand.command
def insert():
    "Insert demo data"

    admin = User("admin", "s3cret")
    db.session.add(admin)
    user1 = User("user1", "s3cret")
    db.session.add(user1)
    db.session.commit()

    category1 = Category(admin.id, "News")
    db.session.add(category1)
    category2 = Category(user1.id, "Blog")
    db.session.add(category2)
    db.session.commit()

    feed1 = Feed("http://feeds.feedburner.com/xda-developers/ShsH")
    db.session.add(feed1)
    feed2 = Feed("http://feeds.mashable.com/Mashable")
    db.session.add(feed2)
    feed3 = Feed("http://feeds.gawker.com/lifehacker/full")
    db.session.add(feed3)

    db.session.commit()




@DevelCommand.command
def drop():
    "Drop all table"
    db.drop_all()


UpdateCommand = Manager(usage = 'Perform database update')

@UpdateCommand.command
def feeds():
    Updater.feeds()



