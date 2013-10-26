import calendar
from datetime import datetime

from flask import *
from flask.ext.security import login_user, logout_user, current_user
from flask.ext.babel import gettext

from ssr import app, db
from ssr.models import User
from ssr.helpers import strip_html_tags
from ssr.repositories import UserEntryRepository


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
