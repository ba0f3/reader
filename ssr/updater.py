from ssr import logger
from ssr.models import *
import datetime
import feedparser
from dateutil import parser
#from sqlalchemy.exc import IntegrityError
import uuid;

import traceback

class Updater:

    @staticmethod
    def feeds():
        feeds = Feed.query.filter_by(update_lock=False).all()
        for feed in feeds:
            logger.debug("Processing feed: %s", feed.id)
            logger.debug("Setting update lock")
            feed.update_lock = True
            feed.last_update_started = datetime.datetime.now()
            db.session.add(feed)
            db.session.commit()

            try:
                logger.debug("Fetching XML data from: %s", feed.feed_url)
                d = feedparser.parse(feed.feed_url)
                logger.debug("Found %s entries", len(d))
                entry_ids = []
                for entry in d.entries:
                    unique_id = uuid.uuid5(uuid.NAMESPACE_URL, str(entry.link))
                    e = Entry.query.filter_by(uuid=unique_id).first()
                    status = "exists"
                    if e is None:
                        status = "done"
                        title = entry.title
                        link = entry.link
                        content = entry.content[0].value if 'content' in entry else entry.summary
                        published = parser.parse(entry.published)
                        author = entry.author
                        comments = entry.comments if 'comments' in entry else None
                        try:
                            e = Entry(feed.id, title, link, unique_id, content, published, author, comments)
                            db.session.add(e)
                            db.session.commit()
                            entry_ids.append(e.id)
                        except Exception as ex:
                            status = "error"
                            logger.error("Error: %s", ex)
                            traceback.print_exc()
                    else:
                        entry_ids.append(e.id)

                    logger.debug("Processing entry [%s] with uuid [%s].... %s", entry.title, unique_id, status)

                # list of users that have current feed
                if len(entry_ids) > 0:
                    user_feeds = UserFeed.query.filter_by(feed_id=feed.id).all()
                    logger.debug("Found %s subscribers for this feed", len(user_feeds))
                    for user_feed in user_feeds:

                        for entry_id in entry_ids:
                            status = "exists"
                            ue = UserEntry.query.filter_by(entry_id=entry_id, user_feed_id=user_feed.id, user_id=user_feed.user_id).first()
                            if ue is None:
                                status = "done"
                                ue = UserEntry(user_feed.user_id, entry_id, user_feed.id)
                                db.session.add(ue)
                                db.session.commit()
                            logger.debug("Adding entry [%s] for user [%s]... %s", entry_id, user_feed.user_id, status)

            except Exception as ex:
                logger.error("Error: %s", ex)
                traceback.print_exc()
                feed.last_error = e.message

            logger.debug("Release update lock for: %s", feed.feed_url)
            feed.update_lock = False
            feed.last_updated = datetime.datetime.now()
            db.session.add(feed)
            db.session.commit()

    def favicons(self):
        pass

    def counter(self):
        pass




