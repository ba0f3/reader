from sqlalchemy.orm import relationship
from werkzeug.security import generate_password_hash, check_password_hash
from flask.ext.login import current_user
from flask.ext.security import UserMixin, RoleMixin
from ssr import db
from ssr.helpers import html_sanitizer
import datetime
import hashlib
import calendar


class Category(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id', ondelete='CASCADE'))
    parent_id = db.Column(db.Integer, default=-1)
    name = db.Column(db.String(255), nullable=False)
    order_id = db.Column(db.Integer, default=None)
    user_feeds = relationship("UserFeed")

    def __init__(self, user_id, name, parent_id=-1, order_id=None):
        self.user_id = user_id
        self.name = name
        self.parent_id = parent_id
        self.order_id = order_id


class Feed(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    feed_url = db.Column(db.Text)
    feed_url_hash = db.Column(db.String(56), unique=True)
    update_interval = db.Column(db.Integer)
    update_lock = db.Column(db.Boolean, default=False)
    site_url = db.Column(db.String(255))
    last_published = db.Column(db.DateTime)
    last_modified = db.Column(db.DateTime)
    last_etag = db.Column(db.String(255), nullable=False, default="")
    last_update_started = db.Column(db.DateTime)
    last_error = db.Column(db.String(255))
    language = db.Column(db.String(10))

    def __init__(self, feed_url):
        self.feed_url = feed_url
        self.feed_url_hash = hashlib.sha224(feed_url).hexdigest()


class UserFeed(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id', ondelete='CASCADE'))
    category_id = db.Column(db.Integer, db.ForeignKey('category.id', ondelete='CASCADE'))
    feed_id = db.Column(db.Integer, db.ForeignKey('feed.id', ondelete='CASCADE'))
    name = db.Column(db.String(255))
    purge_interval = db.Column(db.Integer, default=60)
    last_viewed = db.Column(db.DateTime)
    order_id = db.Column(db.Integer, default=1)
    user_entries = relationship("UserEntry", backref="user_feed")

    def __init__(self, user_id, category_id, feed_id, name):
        self.user_id = user_id
        self.category_id = category_id
        self.feed_id = feed_id
        self.name = name


class Entry(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    uuid = db.Column(db.String(255), unique=True, nullable=False)
    link = db.Column(db.Text, nullable=False)
    content = db.Column(db.Text, nullable=False)
    content_hash = db.Column(db.String(56))
    published = db.Column(db.DateTime, nullable=False)
    created = db.Column(db.DateTime, nullable=False)
    author = db.Column(db.String(255))
    comments = db.Column(db.String(255))
    social_count = db.Column(db.Integer, default=0, nullable=False)
    social_last_update = db.Column(db.DateTime)
    feed_id = db.Column(db.Integer, db.ForeignKey('feed.id', ondelete='CASCADE'))

    def __init__(self, feed_id, title, link, uuid, content, published, author=None, comments=None, created=None):
        content = html_sanitizer(content)
        self.feed_id = feed_id
        self.title = title
        self.link = link
        self.uuid = uuid
        self.content = content
        self.content_hash = Entry.hash_content(content)
        self.published = published
        self.author = author
        self.comments = comments
        self.created = created if created is not None else datetime.datetime.now()

    @staticmethod
    def hash_content(content):
        return hashlib.sha224(content.encode('ascii', 'ignore')).hexdigest()


class UserEntry(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id', ondelete='CASCADE'))
    entry_id = db.Column(db.Integer, db.ForeignKey('entry.id', ondelete='CASCADE'))
    user_feed_id = db.Column(db.Integer, db.ForeignKey('user_feed.id', ondelete='CASCADE'))
    unread = db.Column(db.Boolean, default=True)
    stared = db.Column(db.Boolean, default=False)
    created = db.Column(db.DateTime, nullable=False)
    note = db.Column(db.Text)

    def __init__(self, user_id, entry_id, user_feed_id, note=None, created=None):
        self.user_id = user_id
        self.entry_id = entry_id
        self.user_feed_id = user_feed_id
        self.note = note
        self.created = created if created is not None else datetime.datetime.now()


class Tag(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id', ondelete='CASCADE'))
    user_entry_id = db.Column(db.Integer, db.ForeignKey('user_entry.id', ondelete='CASCADE'))
    name = db.Column(db.String(255), nullable=False)

    def __init__(self, user_id, user_entry_id, name):
        self.user_id = user_id
        self.user_entry_id = user_entry_id
        self.name = name

roles_users = db.Table('roles_users',
                       db.Column('user_id', db.Integer(), db.ForeignKey('user.id', ondelete='CASCADE')),
                       db.Column('role_id', db.Integer(), db.ForeignKey('role.id', ondelete='CASCADE')))


class Role(db.Model, RoleMixin):
    id = db.Column(db.Integer(), primary_key=True)
    name = db.Column(db.String(80), unique=True)
    description = db.Column(db.String(255))


class User(db.Model, UserMixin):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(100), unique=True, nullable=False)
    password = db.Column(db.String(100), nullable=False)
    active = db.Column(db.Boolean, default=False)
    last_login = db.Column(db.DateTime)
    access_level = db.Column(db.Integer, default=1)
    email = db.Column(db.String(255), unique=True, nullable=False)
    full_name = db.Column(db.String(255))
    created = db.Column(db.DateTime)
    locale = db.Column(db.String(10))
    timezone = db.Column(db.String(50))
    categories = relationship("Category")
    user_feeds = relationship("UserFeed")
    roles = db.relationship('Role', secondary=roles_users,
                            backref=db.backref('users', lazy='dynamic'))

    def __init__(self, username, password, email, active=True, full_name=None, access_level = 1):
        self.username = username
        if password is not None:
            self.set_password(password)
        self.email = email
        self.full_name = full_name
        self.active = active
        self.access_level = access_level
        self.created = datetime.datetime.now()

    def set_password(self, password):
        self.password = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password, password)

    def is_authenticated(self):
        return self.id == current_user.id

    def get_id(self):
        return unicode(self.id)

    def get_profile(self):
        return {
            'id': self.id,
            'username': self.username,
            'last_login': calendar.timegm(self.last_login.utctimetuple()),
            'email': self.email,
            'full_name': self.full_name,
            'locale': self.locale,
            'timezone': self.timezone
        }


class FeedUnreadCache(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id', ondelete='CASCADE'))
    user_feed_id = db.Column(db.Integer, db.ForeignKey('user_feed.id', ondelete='CASCADE'), unique=True)
    value = db.Column(db.Integer, default=0, nullable=False)
    last_update = db.Column(db.DateTime, nullable=False)

    def __init__(self, user_id, user_feed_id, value=0, last_update=0):
        self.user_id = user_id
        self.user_feed_id = user_feed_id
        self.value = value
        self.last_update = last_update

    def increase(self, value):
        self.value += value

    def decrease(self, value):
        self.value -= value


class CategoryUnreadCache(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id', ondelete='CASCADE'))
    category_id = db.Column(db.Integer, db.ForeignKey('category.id', ondelete='CASCADE'), unique=True)
    value = db.Column(db.Integer, default=0, nullable=False)
    last_update = db.Column(db.DateTime, nullable=False)

    def __init__(self, user_id, category_id, value=0, last_update=0):
        self.user_id = user_id
        self.category_id = category_id
        self.value = value
        self.last_update = last_update


    def increase(self, value):
        self.value += value

    def decrease(self, value):
        self.value -= value


