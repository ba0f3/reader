from sqlalchemy.orm import relationship
from werkzeug.security import generate_password_hash, check_password_hash
from flask.ext.login import current_user
from ssr import db
import uuid

class Category(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    name = db.Column(db.String(255))
    feeds = relationship("Feed")

    def __init__(self, user_id=None, name=None):
        self.user_id = user_id
        self.name = name


class Feed(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    category_id = db.Column(db.Integer, db.ForeignKey('category.id'))
    name = db.Column(db.String(255))
    feed_url = db.Column(db.Text)
    update_interval = db.Column(db.Integer)
    last_updated = db.Column(db.DateTime)

    def __init__(self, name=None, feed_url=None):
        self.name = name
        self.feed_url = feed_url


class Entry(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    uuid = db.Column(db.String(255), unique=True, nullable=False)
    link = db.Column(db.Text, nullable=False)
    content = db.Column(db.Text, nullable=False)
    published = db.Column(db.DateTime, nullable=False)
    author = db.Column(db.String(255))
    comments = db.Column(db.String(255))

    def __init__(self, title=None, link=None, content=None, published=None, author=None, comments=None):
        self.title = title
        self.link = link
        self.uuid = uuid.uuid5(uuid.NAMESPACE_URL, str(link))
        self.content = content
        self.published = published
        self.author = author
        self.comments = comments


class UserEntry(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    entry_id = db.Column(db.Integer, db.ForeignKey('entry.id'))
    feed_id = db.Column(db.Integer, db.ForeignKey('feed.id'))
    unread = db.Column(db.Boolean, default=True)
    note = db.Column(db.Text)


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
    categories = relationship("Category")

    def __init__(self, username=None, password=None, active=True):
        self.username = username
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
