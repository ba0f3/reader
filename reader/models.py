from werkzeug.security import generate_password_hash, check_password_hash
from flask.ext.security import UserMixin, RoleMixin
from .contrib.rwrapper import rwrapper, fields
from reader.utils import html_sanitizer
import datetime
import xxhash
import calendar


class Category(rwrapper):
    user_id = fields.IntegerField()
    parent_id = fields.IntegerField(default=-1)
    name = fields.CharField()
    order_id = fields.IntegerField()


class Feed(rwrapper):
    name = fields.CharField()
    feed_url = fields.CharField()
    feed_url_hash = fields.LongField()
    update_interval = fields.IntegerField()
    update_lock = fields.BooleanField()
    site_url = fields.CharField()
    last_published = fields.DateTimeField()
    last_modified = fields.DateTimeField()
    last_etag = fields.CharField(default='')
    last_update_started = fields.DateTimeField()
    last_error = fields.CharField()
    language = fields.CharField()

    def __init__(self, feed_url):
        self.feed_url = feed_url
        self.feed_url_hash = Feed.get_url_hash(feed_url)

    @staticmethod
    def get_url_hash(url):
        return xxhash.xxh64(url)


class UserFeed(rwrapper):
    user_id = fields.IntegerField()
    category_id = fields.IntegerField()
    feed_id = fields.IntegerField()
    name = fields.CharField()
    purge_interval = fields.IntegerField(default=60)
    last_viewed = fields.DateTimeField()
    order_id = fields.IntegerField(default=1)
    auth_type = fields.BooleanField()
    login = fields.CharField()
    password = fields.CharField()


class Entry(rwrapper):
    title = fields.CharField()
    uuid = fields.CharField()
    link = fields.CharField()
    content = fields.CharField()
    content_hash = fields.LongField()
    published = fields.DateTimeField()
    created = fields.DateTimeField()
    author = fields.CharField()
    comments = fields.CharField()
    social_count = fields.IntegerField()
    social_last_update = fields.DateTimeField()
    feed_id = fields.IntegerField()

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
        return xxhash.xxh64(content.encode('ascii', 'ignore'))


class UserEntry(rwrapper):
    user_id = fields.IntegerField()
    entry_id = fields.IntegerField()
    user_feed_id = fields.IntegerField()
    unread = fields.BooleanField(default=True)
    stared = fields.BooleanField(default=False)
    created = fields.DateTimeField()
    note = fields.CharField()


class User(rwrapper, UserMixin):
    _db_table = 'users'

    username = fields.CharField(unique=True)
    email = fields.EmailField()
    password = fields.CharField()
    active = fields.BooleanField(default=True)
    confirmed_at = fields.DateTimeField(required=False)
    last_login_at = fields.DateTimeField(required=False)
    current_login_at = fields.DateTimeField(required=False)
    last_login_ip = fields.CharField(required=False)
    current_login_ip = fields.CharField(required=False)
    login_count = fields.IntegerField(default=1)
    roles = fields.ObjectField(default=[])

    def set_password(self, password):
        self.password = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password, password)

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

class Role(rwrapper, RoleMixin):
    _db_table = 'roles'

    name = fields.CharField()
    description = fields.CharField()


class FeedUnreadCache(rwrapper):
    user_id = fields.IntegerField()
    user_feed_id = fields.IntegerField()
    value = fields.IntegerField()
    last_update = fields.DateTimeField()

    def increase(self, value):
        self.value += value

    def decrease(self, value):
        self.value -= value


class CategoryUnreadCache(rwrapper):
    user_id = fields.IntegerField()
    category_id = fields.IntegerField()
    value = fields.IntegerField()
    last_update = fields.DateTimeField()

    def increase(self, value):
        self.value += value

    def decrease(self, value):
        self.value -= value
