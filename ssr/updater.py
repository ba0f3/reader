from ssr.models import *
import datetime
import feedparser
from dateutil import parser
#from sqlalchemy.exc import IntegrityError
import uuid;
from logging import Logger


class Updater:

    @staticmethod
    def feeds():
        feeds = Feed.query.filter_by(lock=False).all()
        for feed in feeds:
            print "Processing feed: %s" % feed.name
            print "Locking feed"
            feed.lock = True
            db.session.add(feed)
            db.session.commit()

            print "Fetching XML data"
            d = feedparser.parse(feed.feed_url)
            for entry in d.entries:
                unique_id = uuid.uuid5(uuid.NAMESPACE_URL, str(entry.link))
                e = Entry.query.filter_by(uuid=unique_id).first()
                if(e is None):
                    title = entry.title
                    link = entry.link
                    content = entry.content[0].value if 'content' in entry else entry.summary
                    published = parser.parse(entry.published)
                    author = entry.author
                    comments = entry.comments if 'comments' in entry else None

                    e = Entry(title, link, unique_id, content, published, author, comments)
                    db.session.add(e)
                    db.session.commit()

                    ue = UserEntry(entry_id=e.id, user_id=feed.user_id, feed_id=feed.id)
                    db.session.add(ue)
                    db.session.commit()
                else:
                    ue = UserEntry.query.filter_by(entry_id=e.id, user_id=feed.user_id, feed_id=feed.id).first()
                    if(ue is None):
                        ue = UserEntry(entry_id=e.id, user_id=feed.user_id, feed_id=feed.id)
                        db.session.add(ue)
                        db.session.commit()

            print "Release lock for: %s" % feed.name
            feed.lock = False
            feed.last_updated = datetime.datetime.now()
            db.session.add(feed)
            db.session.commit()

    def favicons(self):
        pass

    def counter(self):
        pass




