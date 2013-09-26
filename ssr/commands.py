from flask.ext.script import Command
from ssr import db
from ssr.models import *
import feedparser
from dateutil import parser


class InsertDemoDataCommand(Command):
    "Insert demo data"

    def run(self):
        admin = User("admin", "s3cret")
        db.session.add(admin)

        category = Category(admin.id, "News")
        db.session.add(category)

        feed = Feed("XDA", "http://feeds.feedburner.com/xda-developers/ShsH")
        db.session.add(feed)

        db.session.commit()


class TestRssClient(Command):
    "Test RSS Client"

    def run(self):
        uid = 1
        user = User.query.get(uid)
        for cat in user.categories:
            for feed in cat.feeds:
                d = feedparser.parse(feed.feed_url)
                for entry in d.entries:
                    e = Entry(entry.title, entry.link, entry.content[0].value, parser.parse(entry.published), entry.author, entry.comments)
                    db.session.add(e)
                db.session.commit()




