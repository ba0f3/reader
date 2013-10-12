from flask.ext.script import Manager
from ssr import db
from ssr.models import Category, User, Entry, UserFeed, Feed
from ssr.helpers import import_opml, html_sanitizer
from ssr.counter import count_all
from multiprocessing import Pool


DevelCommand = Manager(usage="Useful commands for development")

@DevelCommand.command
def insert():
    "Insert demo data"

    admin = User("admin", "s3cret", "admin@example.com", full_name="Administrator")
    db.session.add(admin)
    user1 = User("user1", "s3cret", "user1@example.com", full_name="Test User 1")
    db.session.add(user1)
    db.session.commit()

    cat_admin_news = Category(admin.id, "News")
    db.session.add(cat_admin_news)
    cat_admin_magazine = Category(admin.id, "Magazine")
    db.session.add(cat_admin_magazine)
    cat_user1_blog = Category(user1.id, "Blog")
    db.session.add(cat_user1_blog)

    db.session.commit()

    feed_xda = Feed("http://feeds.feedburner.com/xda-developers/ShsH")
    db.session.add(feed_xda)
    feed_mashable = Feed("http://feeds.mashable.com/Mashable")
    db.session.add(feed_mashable)
    feed_lifehacker = Feed("http://feeds.gawker.com/lifehacker/full")
    db.session.add(feed_lifehacker)

    db.session.commit()

    uf1 = UserFeed(admin.id, cat_admin_news.id, feed_xda.id, "XDA")
    db.session.add(uf1)
    uf2 = UserFeed(admin.id, cat_admin_news.id, feed_mashable.id, "Mashable")
    db.session.add(uf2)
    uf3 = UserFeed(admin.id, cat_admin_magazine.id, feed_lifehacker.id, "Life Hacker")
    db.session.add(uf3)

    uf4 = UserFeed(user1.id, cat_user1_blog.id, feed_lifehacker.id, "Lifehacker")
    db.session.add(uf4)
    uf5 = UserFeed(user1.id, cat_user1_blog.id, feed_mashable.id, "Mash")
    db.session.add(uf5)
    db.session.commit()

@DevelCommand.command
def drop():
    "Drop all table"
    db.drop_all()

@DevelCommand.option('-u', '--user-id', dest='uid', help="User for import data to")
@DevelCommand.option('-p', '--path', dest='path', help="Path to local OPML file or online url")
def opml(uid, path):
    "Import OPML"
    import_opml(uid, path)

@DevelCommand.command
def sanitizer():
    entries = Entry.query.all()

    for entry in entries:
        print "========================"
        print "Original:"
        print "========================"
        print entry.content_hash
        print entry.content
        result = html_sanitizer(entry.content)
        print "========================"
        print "Cleaned:"
        print "========================"
        print result
        entry.content = result
        entry.content_hash = Entry.hash_content(result)
        db.session.add(entry)
    db.session.commit()

@DevelCommand.option('-u', '--url', dest='url', help="Url to receive counts")
def count(url):
    """Get social share count for an url"""

    print count_all(url)
