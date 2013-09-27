from flask.ext.script import Manager, Command
from ssr import db
from ssr.models import *
import feedparser
from dateutil import parser
from ssr import app
from ssr.updater import Updater;
import uuid;

DemoCommand = Manager(usage="Create/update demo data")

@DemoCommand.command
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

    feed = Feed("XDA", "http://feeds.feedburner.com/xda-developers/ShsH", admin.id, category1.id)
    db.session.add(feed)
    feed = Feed("Mashable", "http://feeds.mashable.com/Mashable", admin.id, category1.id)
    db.session.add(feed)
    feed = Feed("Lifehacker", "http://feeds.gawker.com/lifehacker/full", admin.id, category1.id)
    db.session.add(feed)
    feed = Feed("Lifehacker", "http://feeds.gawker.com/lifehacker/full", user1.id, category2.id)
    db.session.add(feed)

    db.session.commit()


@DemoCommand.command
def drop():
    "Drop all table"
    db.drop_all()


class TestRssClient(Command):
    "Test RSS Client"

    def run(self):
        uid = 1
        user = User.query.get(uid)
        for cat in user.categories:
            for feed in cat.feeds:
                d = feedparser.parse(feed.feed_url)
                for entry in d.entries:
                    unique_id = uuid.uuid5(uuid.NAMESPACE_URL, str(entry.link))
                    e = Entry(entry.title, entry.link, unique_id, entry.content[0].value, parser.parse(entry.published), entry.author, entry.comments)
                    db.session.add(e)
                db.session.commit()


UpdateCommand = Manager(usage = 'Perform database update')

@UpdateCommand.command
def feeds():
    Updater.feeds()



