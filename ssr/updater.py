from ssr import logger
import ssr.configs
from ssr.models import *
from datetime import datetime, timedelta
import feedparser
from dateutil import parser
#from sqlalchemy.exc import IntegrityError
import uuid;
import ssr.configs
from urlparse import urlparse
import traceback

class Updater:

    @staticmethod
    def feeds():
        #TODO: check update interval &
        feeds = Feed.query.filter_by(update_lock=False).all()
        for feed in feeds:
            logger.debug("Processing feed: %s <%s>", feed.id, feed.feed_url)

            if feed.update_interval is None:
                update_interval = ssr.configs.FEED_UPDATE_TTL
            else:
                update_interval = feed.update_interval

            if feed.last_updated is not None:
                if feed.last_updated + timedelta(minutes=update_interval) > datetime.now():
                    logger.info("This feed is recently updated, ignore")
                    continue

            logger.debug("Setting update lock")
            feed.update_lock = True
            feed.last_update_started = datetime.now()
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
                        author = entry.author if 'author' in entry else None
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
                feed.last_error = ex.message

            logger.debug("Release update lock for: %s", feed.feed_url)
            feed.update_lock = False
            db.session.add(feed)
            db.session.commit()

    @staticmethod
    def metadata(feed_id=None):
        update_periods = {
            'hourly': 60,
            'daily': 1440,
            'weekly': 10080,
            'monthly': 43200,
            'yearly': 525600
        }
        if feed_id is None:
            feeds = Feed.query.all()
        else:
            feeds = Feed.query.filter_by(id=feed_id).all()
        for feed in feeds:
            d = feedparser.parse(feed.feed_url)
            #title = d.channel.title
            url = urlparse(d.channel.link)
            link = "%s://%s" % (url.scheme, url.netloc)
            #update_interval = ssr.configs.FEED_UPDATE_TTL
            if 'ttl' in d.channel:
                update_interval = d.channel.ttl
            else:
                "The period over which the channel is updated. Allowed values are 'hourly', 'daily', 'weekly', 'monthly', 'yearly'. If omitted, 'daily' is assumed."
                update_period = d.channel.sy_updateperiod if 'sy_updateperiod' in d.channel else ssr.configs.FEED_UPDATE_PERIOD
                "Frequency of updates, in relation to sy_updateperiod. Indicates how many times in each sy_updateperiod the channel is updated."
                update_frequency = int(d.channel.sy_updatefrequency) if 'sy_updatefrequency' in d.channel else ssr.configs.FEED_UPDATE_FREQUENCY

                update_interval = update_periods[update_period] / update_frequency

            feed.site_url = link
            feed.update_interval = update_interval

            db.session.add(feed)
            db.session.commit()


    def counter(self):
        pass




