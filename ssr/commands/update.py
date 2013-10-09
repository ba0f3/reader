from flask.ext.script import Manager
from ssr import logger
import ssr.configs
from ssr.models import *
from time import mktime
from datetime import datetime, timedelta
import feedparser
import uuid
import ssr.configs
from urlparse import urlparse
import traceback


UpdateCommand = Manager(usage='Perform database update')
@UpdateCommand.command
def feeds():
    "Update feed entries"
    #TODO: check update interval &
    feeds = Feed.query.filter_by(update_lock=False).all()
    for feed in feeds:
        logger.debug("Processing feed: %s <%s>", feed.id, feed.feed_url)

        if feed.update_interval is None:
            update_interval = ssr.configs.FEED_UPDATE_TTL
        else:
            update_interval = feed.update_interval

        if feed.last_update_started is not None:
            if feed.last_update_started + timedelta(minutes=update_interval) > datetime.now():
                logger.info("This feed is recently fetched")
                continue

        logger.debug("Setting update lock")
        feed.update_lock = True
        feed.last_update_started = datetime.now()
        db.session.add(feed)
        db.session.commit()

        try:
            logger.debug("Fetching XML data from: %s", feed.feed_url)
            d = feedparser.parse(feed.feed_url, etag=feed.last_etag, modified=feed.last_modified, agent="Breakfast https://github.com/VN-Nerds/breakfast")

            if not d.feed:
                logger.debug("This feed has not been modified since last fetch")
            else:
                try:
                    last_published = d.feed.published_parsed if 'published_parsed' in d.feed else d.feed.updated_parsed if 'updated_parsed' in d.feed else None
                    last_published = datetime.fromtimestamp(mktime(last_published))
                except Exception:
                    last_published = None

                entry_ids = []
                if last_published and feed.last_published and feed.last_published >= last_published:
                    logger.debug("This feed has not been updated since last fetch")
                else:
                    feed.last_published = last_published

                    feed.last_etag = d.etag if 'etag' in d else ""
                    feed.last_modified = datetime.fromtimestamp(mktime(d.modified_parsed)) if 'modified_parsed' in d else None

                    logger.debug("Found %s entries", len(d))

                    if d.entries:
                        for entry in d.entries:
                            unique_id = uuid.uuid5(uuid.NAMESPACE_URL, str(entry.link))
                            e = Entry.query.filter_by(uuid=unique_id).first()
                            status = "exists"
                            if e is None:
                                status = "done"
                                title = entry.title
                                link = entry.link
                                content = entry.content[0].value if 'content' in entry else entry.summary
                                try:
                                    published = entry.published_parsed if 'published_parsed' in entry else entry.updated_parsed if 'updated_parsed' in entry else None
                                    published = datetime.fromtimestamp(mktime(published))
                                except:
                                    published = None
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
                if entry_ids:
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

                feed.last_error = ""  # clear error message
        except Exception as ex:
            logger.error("Error: %s", ex)
            traceback.print_exc()
            feed.last_error = str(ex)

        logger.debug("Release update lock for: %s", feed.feed_url)
        feed.update_lock = False

        db.session.add(feed)
        db.session.commit()

@UpdateCommand.command
def metadata(feed_id=None):
    "Update feed metadata, such as: site url, favicon, update interval"
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
        feed.language = d.feed.language

        db.session.add(feed)
        db.session.commit()

@UpdateCommand.command
def unread():
    "Update global unread cache"

    logger.debug("Updating global unread cache:")
    sql = "INSERT INTO feed_unread_cache (user_id, user_feed_id, value, last_update) \
            SELECT user_id, user_feed_id, value, last_update FROM ( \
                SELECT ue.user_id, ue.user_feed_id, COUNT(ue.id) as value, NOW() AS last_update \
                FROM user_entry as ue \
                WHERE ue.unread=1 \
                GROUP BY ue.user_feed_id \
            ) AS t \
        ON DUPLICATE KEY UPDATE value=t.value"

    result = db.engine.execute(sql)
    logger.debug("feed_unread_cache: %s affected", result.rowcount)

    sql = "INSERT INTO category_unread_cache (user_id, category_id, value, last_update) \
            SELECT user_id, category_id, value, last_update FROM ( \
                SELECT fuc.user_id, uf.category_id, SUM(fuc.value) as value, NOW() AS last_update  \
                FROM feed_unread_cache as fuc \
                INNER JOIN user_feed AS uf on uf.id = fuc.user_feed_id \
                GROUP BY uf.category_id \
            ) AS t \
        ON DUPLICATE KEY UPDATE value=t.value"

    result = db.engine.execute(sql)
    logger.debug("category_unread_cache: %s affected", result.rowcount)