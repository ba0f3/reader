import calendar
from datetime import datetime

from flask import *
from flask.ext.security import login_user, logout_user, current_user
from flask.ext.babel import gettext

from ssr import app, db
from ssr.models import User, Category, UserFeed, Feed, Entry, UserEntry, FeedUnreadCache
from ssr.helpers import strip_html_tags
from ssr.commands import update
from ssr.repositories import UserEntryRepository, UserFeedRepository, CategoryRepository, CategoryUnreadCacheRepository, FeedUnreadCacheRepository, FeedRepository
import feedparser


def make_error(message, error_code=0, status_code=500):
    response = jsonify(error={'message': message, 'code': error_code})
    response.status_code = status_code
    return response

@app.route('/', methods=['GET'])
def index():
    template = 'index-debug.html' if app.debug is True else 'index.html'
    return render_template(template)

@app.route('/openSession', methods=['POST'])
def open_session():
    if current_user.is_authenticated():
        return jsonify(open=True, user=current_user.get_profile())
    else:
        return make_error(gettext('Unauthorized!'), 401, 401)



@app.route('/login', methods=['POST'])
def login():
    if request.json is None:
        return make_error(gettext('Request method is not supported'), 400)

    username = request.json['username'] if 'username' in request.json else None
    password = request.json['password'] if 'username' in request.json else None
    remember = request.json['remember'] if 'remember' in request.json else False

    if username is None or password is None:
        return make_error(gettext('Username and password are required!'))

    user = User.query.filter_by(username=username).first()
    if user is None or user.check_password(password) is False:
        return make_error(gettext('Invalid username or password!'))
    else:
        if login_user(user, remember):
            user.last_login = datetime.now()
            db.session.add(user)
            db.session.commit()
            return jsonify(login=True, authToken=user.get_auth_token(), user=user.get_profile())


@app.route("/logout", methods=['POST'])
def logout():
    if current_user.is_authenticated():
        logout_user()
        return jsonify(logout=True)
    else:
        return make_error(gettext("User is not logged in!"))

@app.route('/api/categories', methods=['POST'])
def get_categories():
    if current_user.is_authenticated() is False:
        return make_error(gettext('Unauthorized!'), 401, 401)

    user_id = current_user.id

    category_list = list()
    feed_list = list()

    sql = "SELECT c.id, c.name, c.order_id, c.parent_id, cuc.value AS unread \
    FROM category AS c \
    INNER JOIN category_unread_cache AS cuc ON c.id = cuc.category_id \
    WHERE c.user_id=%s \
    ORDER BY c.name, c.order_id" % user_id

    rows = db.engine.execute(sql)
    for row in rows:
        category_list.append({
            'id': row.id,
            'name': row.name,
            'order_id': row.order_id,
            'parent_id': row.parent_id,
            'unread': row.unread})

    sql = "SELECT f.id, uf.category_id, uf.name, uf.order_id, f.site_url, fuc.value AS unread \
    FROM user_feed AS uf \
    INNER JOIN feed AS f ON f.id = uf.feed_id \
    INNER JOIN feed_unread_cache AS fuc ON uf.id = fuc.user_feed_id"

    rows = db.engine.execute(sql)
    for row in rows:
        feed_list.append({
            'id': row.id,
            'name': row.name,
            'category_id': row.category_id,
            'order_id': row.order_id,
            'site': row.site_url,
            'unread': row.unread})

    return jsonify(load=True, categories=category_list, feeds=feed_list)


@app.route('/api/headlines', methods=['POST'])
def get_headlines():
    RSSHeadlineOrderByNewestFirst = 1
    RSSHeadlineOrderByOldestFirst = 2
    #RSSHeadlineOrderByTitle = 3

    RSSHeadlineNoFilter = 1
    RSSHeadlineFilterByStared = 2
    RSSHeadlineFilterByUnread = 3
    RSSHeadlineFilterByArchives = 4
    RSSHeadlineFilterByUnreadFirst = 5

    if current_user.is_authenticated() is False:
        return make_error(gettext('Unauthorized!'), 401, 401)

    if request.json is None:
        return make_error(gettext('Request method is not supported'), 400)

    category = request.json['category'] if 'category' in request.json else None
    feed = request.json['feed'] if 'feed' in request.json else None
    last_timestamp = request.json['lastTimestamp'] if 'lastTimestamp' in request.json else None
    order_mode = request.json['orderMode'] if 'orderMode' in request.json else RSSHeadlineOrderByNewestFirst
    filter_mode = request.json['filterMode'] if 'filterMode' in request.json else RSSHeadlineFilterByUnreadFirst

    user_id = current_user.id

    filters = list()
    orders = list()
    extra_joins = list()
    filters.append("ue.user_id = %s" % user_id)

    if filter_mode == RSSHeadlineFilterByUnreadFirst:
        orders.append("ue.unread DESC")
    elif filter_mode == RSSHeadlineFilterByUnread:
        filters.append("ue.unread = 1")
    elif filter_mode == RSSHeadlineFilterByStared:
        filters.append("ue.stared = 1")

    if category > 0:
        extra_joins.append("INNER JOIN user_feed AS uf ON uf.id = ue.user_feed_id")
        filters.append("uf.category_id = %s" % category)
    elif feed > 0:
        filters.append("e.feed_id = %s" % feed)

    if last_timestamp > 0:
        if order_mode == RSSHeadlineOrderByNewestFirst:  
            filters.append("ue.created < '%s'" % datetime.utcfromtimestamp(last_timestamp))
        elif order_mode == RSSHeadlineOrderByOldestFirst: 
            filters.append("ue.created > '%s'" % datetime.utcfromtimestamp(last_timestamp))
    
    if order_mode == RSSHeadlineOrderByNewestFirst:
        orders.append("ue.created DESC")
    elif order_mode == RSSHeadlineOrderByOldestFirst:
        orders.append("ue.created ASC")
    else:
        orders.append("e.title ASC")

    headline_list = list()
    sql = "SELECT ue.id, e.title, f.site_url, e.content, ue.unread, ue.stared, ue.created \
        FROM user_entry AS ue \
        INNER JOIN entry AS e ON e.id = ue.entry_id \
        INNER JOIN feed AS f ON f.id = e.feed_id %s  \
        WHERE %s \
        ORDER BY %s \
        LIMIT 20" % (' '.join(extra_joins), ' AND '.join(filters), ', '.join(orders))

    rows = db.engine.execute(sql)

    for row in rows:
        entry = {
            'id': row.id,
            'title': row.title,
            'site': row.site_url,
            'intro': strip_html_tags(row.content).strip(),  # TODO: tao intro ngay khi update feed
            'created': calendar.timegm(row.created.utctimetuple()),
            'unread': row.unread,
            'stared': row.stared
        }
        headline_list.append(entry)
    return jsonify(count=len(headline_list), objects=headline_list)


@app.route('/api/entry/<int:user_entry_id>', methods=['POST'])
def get_entries(user_entry_id):
    if current_user.is_authenticated() is False:
        return make_error(gettext('Unauthorized!'), 401, 401)

    user_id = current_user.id

    sql = """SELECT
            ue.id, e.title, e.link, f.site_url, e.content, uf.feed_id, uf.category_id,
            e.published, e.author, e.comments, ue.unread, ue.stared, ue.note
        FROM user_entry AS ue
        INNER JOIN entry AS e ON e.id = ue.entry_id
        INNER JOIN feed AS f ON f.id = e.feed_id
        INNER JOIN user_feed AS uf ON f.id = uf.feed_id
        WHERE ue.user_id = %s
        AND ue.id = %s
        LIMIT 1""" % (user_id, user_entry_id)
    rows = db.engine.execute(sql)
    #FIXME: how to get single result???
    for row in rows:
        entry = {
            'id': row.id,
            'title': row.title,
            'site': row.site_url,
            'link': row.link,
            'content': row.content,
            'published': calendar.timegm(row.published.utctimetuple()),
            'author': row.author,
            'comments': row.comments,
            'unread': row.unread,
            'stared': row.stared,
            'note': row.note,
            'feed_id': row.feed_id,
            'category_id': row.category_id
        }
        return jsonify(objects=entry)
    return make_error(gettext('Entry not found'), 404)


@app.route('/api/markers', methods=['POST'])
def marker():
    if current_user.is_authenticated() is False:
        return make_error(gettext('Unauthorized!'), 401, 401)

    if request.json is None:
        return make_error(gettext('Request method is not supported'), 400)

    action = request.json['action'] if 'action' in request.json else None
    type = request.json['type'] if 'type' in request.json else None
    id = request.json['id'] if 'id' in request.json else None

    if action is None or type is None or id is None:
        return make_error(gettext('Required parameters are missing'))

    if action == 'markAsRead':
        if type == 'entry':
            result = UserEntryRepository.markAsRead(id)
            if result == 404:
                return make_error(gettext('Entry not found'), 404)
            elif result == 304:
                return jsonify(marked=False)
            else:
                return jsonify(marked=True)

@app.route('/api/category', methods=['POST'])
def category():
    if current_user.is_authenticated() is False:
        return make_error(gettext('Unauthorized!'), 401, 401)

    if request.json is None:
        return make_error(gettext('Request method is not supported'), 400)

    action = request.json['action'] if 'action' in request.json else None

    if action == 'create':
        name = request.json['name'] if 'name' in request.json else None
        if not name:
            return make_error(gettext('Category name is required.'))

        try:
            category = CategoryRepository.create(current_user.id, name)
            return jsonify(create=True, category={
                'id': category.id,
                'name': category.name,
                'order_id': category.order_id,
                'parent_id': category.parent_id,
                'unread': 0})
        except:
            return make_error(gettext('Error! please try again later.'))
    elif action == 'delete':
        id = request.json['id'] if 'id' in request.json else None
        if not id:
            return make_error(gettext('Category ID is required.'))

        try:
            category = Category.query.get(id)
            if category.user_feeds:
                return make_error(gettext('Please unsubscribe feeds belong category %s first.', category.name))

            db.session.delete(category)
            db.session.commit()

            return jsonify(delete=True, id=id)
        except:
            return make_error(gettext('Error! please try again later.'))

    elif action == 'rename':
        id = request.json['id'] if 'id' in request.json else None
        name = request.json['name'] if 'name' in request.json else None

        if not id and not name:
            return make_error(gettext('Required parameters are missing.'))

        category = Category.query.get(id)
        category.name = name
        CategoryRepository.save(category)

        return jsonify(rename=True, id=id, name=name)

    return make_error(gettext('Bad request.'))


@app.route('/api/feed', methods=['POST'])
def feed():
    if current_user.is_authenticated() is False:
        return make_error(gettext('Unauthorized!'), 401, 401)

    if request.json is None:
        return make_error(gettext('Request method is not supported'), 400)

    action = request.json['action'] if 'action' in request.json else None

    if action == 'subscribe':
        url = request.json['url'] if 'url' in request.json else None
        category_id = request.json['cid'] if 'cid' in request.json else None
        #username = request.json['username'] if 'username' in request.json else None
        #password = request.json['password'] if 'password' in request.json else None

        url_hash = Feed.get_url_hash(url)
        print url_hash

        feed = Feed.query.filter_by(feed_url_hash=url_hash).first()

        if feed:
            uf = UserFeed.query.filter_by(feed_id=feed.id, user_id=current_user.id).first()
            if uf:
                return jsonify(subscribe=True, error=500, message=gettext("You are already subscribe to this feed"))
            else:
                uf = UserFeedRepository.create(current_user.id, category_id, feed.id, feed.name)

                entries = Entry.query.filter_by(feed_id=feed.id).all()
                for entry in entries:
                    UserEntryRepository.create(current_user.id, entry.id, uf.id)

                fuc = FeedUnreadCache.query.filter_by(user_feed_id=uf.id).first()
                fuc.value = len(entries)
                fuc.last_update = datetime.now()
                FeedUnreadCacheRepository.save(fuc)

                CategoryUnreadCacheRepository.update(category_id)

                return jsonify(subscribe=True, feed={
                    'id': feed.id,
                    'name': feed.name,
                    'category_id': category_id,
                    'order_id': uf.order_id,
                    'site': feed.site_url,
                    'unread': fuc.value})
        else:
            d = feedparser.parse(url, agent="Breakfast https://github.com/VN-Nerds/breakfast")
            if d.bozo == 1:  # error
                print d.status
                if 'status' in d and d.status == 401:  # password protected
                    return jsonify(subscribe=True, error=401, message=gettext("Password protected feeds are not supported yet."))
                else:
                    return jsonify(subscribe=True, error=500)

            feed = FeedRepository.create(url)
            update.metadata(feed.id)
            uf = UserFeedRepository.create(current_user.id, category_id, feed.id, feed.name)
            return jsonify(subscribe=True, feed={
                'id': feed.id,
                'name': feed.name,
                'category_id': category_id,
                'order_id': uf.order_id,
                'site': feed.site_url,
                'unread': 0})

    elif action == 'unsubscribe':
        id = request.json['id'] if 'id' in request.json else None

        if not id:
            return make_error(gettext('Feed ID is required.'))

        user_feed = UserFeed.query.filter_by(feed_id=id, user_id=current_user.id).first()

        if not user_feed:
            return make_error(gettext('Feed not found.'))

        db.session.delete(user_feed)
        db.session.commit()

        CategoryUnreadCacheRepository.update(user_feed.category_id)

        return jsonify(unsubscribe=True, fid=id, cid=user_feed.category_id)