from HTMLParser import HTMLParser
import opml
from ssr import db
from ssr.models import *

class HTMLStripper(HTMLParser):
    def __init__(self):
        self.reset()
        self.fed = []

    def handle_data(self, d):
        self.fed.append(d)

    def get_data(self):
        return ''.join(self.fed)


def strip_html_tags(html):
    s = HTMLStripper()
    s.feed(html)
    return s.get_data()

def import_opml(user_id, path):
    _opml = opml.parse(path)

    uncategorized = None
    for outline in _opml:
        if hasattr(outline, 'xmlUrl'):
            if uncategorized is None: # does not defined yet
                uncategorized = Category.query.filter_by(user_id=user_id, name="Uncategorized").first()
                if uncategorized is None: # not found
                    uncategorized = Category(user_id, "Uncategorized", order_id=9999)
                    db.session.add(uncategorized)
                    db.session.commit()

            feed = Feed(outline.xmlUrl)
            db.session.add(feed)
            db.session.commit()

            userFeed = UserFeed(user_id, uncategorized.id, feed.id, outline.text)
            db.session.add(userFeed)
            db.session.commit()
        else:
            category = Category.query.filter_by(user_id=user_id, name=outline.text).first()
            if category is None:
                category = Category(user_id, outline.text)
                db.session.add(category)
                db.session.commit()

            for child in outline:
                if hasattr(child, 'xmlUrl'):
                    hash = hashlib.sha224(child.xmlUrl).hexdigest()
                    feed = Feed.query.filter_by(feed_url_hash=hash).first()
                    if feed is None:
                        feed = Feed(child.xmlUrl)
                        db.session.add(feed)
                        db.session.commit()

                    userFeed = UserFeed(user_id, category.id, feed.id, child.text)
                    db.session.add(userFeed)
                    db.session.commit()
                else:
                    logger.warn("Nested category is not supported yet, ignored!")