from sqlalchemy.orm import relationship
from werkzeug.security import generate_password_hash, check_password_hash
from flask.ext.login import current_user
from ssr import db


class Category(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    parent_id = db.Column(db.Integer, default=-1)
    name = db.Column(db.String(255))
    order_id = db.Column(db.Integer, default=None)
    user_feeds = relationship("UserFeed")

    def __init__(self, user_id=None, name=None):
        self.user_id = user_id
        self.name = name


class Feed(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    feed_url = db.Column(db.Text)
    update_interval = db.Column(db.Integer)
    last_updated = db.Column(db.DateTime)
    last_update_started = db.Column(db.DateTime)
    update_lock = db.Column(db.Boolean, default=False)
    last_error = db.Column(db.String(255))
    site_url = db.Column(db.String(255))
    favicon_url = db.Column(db.String(255))
    last_favicon_checked = db.Column(db.DateTime)

    def __init__(self, feed_url=None):
        self.feed_url = feed_url


class UserFeed(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    category_id = db.Column(db.Integer, db.ForeignKey('category.id'))
    feed_id = db.Column(db.Integer, db.ForeignKey('feed.id'))
    name = db.Column(db.String(255))
    purge_interval = db.Column(db.Integer)
    last_viewed = db.Column(db.DateTime)
    order_id = db.Column(db.Integer, default=1)


class Entry(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    uuid = db.Column(db.String(255), unique=True, nullable=False)
    link = db.Column(db.Text, nullable=False)
    content = db.Column(db.Text, nullable=False)
    published = db.Column(db.DateTime, nullable=False)
    author = db.Column(db.String(255))
    comments = db.Column(db.String(255))
    feed_id = db.Column(db.Integer, db.ForeignKey('feed.id'))

    def __init__(self, title=None, link=None, uuid=None, content=None, published=None, author=None, comments=None):
        self.title = title
        self.link = link
        self.uuid = uuid
        self.content = content
        self.published = published
        self.author = author
        self.comments = comments


class UserEntry(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    entry_id = db.Column(db.Integer, db.ForeignKey('entry.id'))
    user_feed_id = db.Column(db.Integer, db.ForeignKey('user_feed.id'))
    unread = db.Column(db.Boolean, default=True)
    started = db.Column(db.Boolean, default=False)
    note = db.Column(db.Text)

    def __init__(self, user_id=None, entry_id=None, feed_id=None, note=None):
        self.user_id = user_id
        self.entry_id = entry_id
        self.feed_id = feed_id
        self.note = note


class Tag(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    user_entry_id = db.Column(db.Integer, db.ForeignKey('user_entry.id'))
    name = db.Column(db.String(255), nullable=False)


class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(100))
    password = db.Column(db.String(100))
    active = db.Column(db.Boolean, default=False)
    last_login = db.Column(db.DateTime)
    access_level = db.Column(db.Integer, default=1)
    email = db.Column(db.String(255))
    full_name = db.Column(db.String(255))
    created = db.Column(db.DateTime)
    categories = relationship("Category")
    user_feeds = relationship("UserFeed")

    def __init__(self, username=None, password=None, active=True):
        self.username = username
        if(password is not None):
            self.set_password(password)
        self.active = active

    def get(self, uid):
        return User.query.get(uid)

    def set_password(self, password):
        self.password = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password, password)

    def is_authenticated(self):
        return self.id == current_user.id

    def is_active(self):
        return self.active == 1

    def is_anonymous(self):
        return False

    def get_id(self):
        return unicode(self.id)
