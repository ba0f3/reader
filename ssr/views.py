from flask import *
from flask.ext.security import login_user, logout_user, current_user
from flask.ext.babel import gettext
from ssr import app, db, logger
from ssr.models import User
from ssr.helpers import strip_html_tags


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
    if current_user.is_authenticated() is False:
        return make_error(gettext('Unauthorized!'), 401, 401)

    user_id = current_user.id
    headline_list = list()
    sql = """SELECT
            ue.id, e.title, f.site_url, e.content, ue.unread, ue.stared
        FROM user_entry AS ue
        INNER JOIN entry AS e ON e.id = ue.entry_id
        INNER JOIN feed AS f ON f.id = e.feed_id
        WHERE ue.user_id = %s
        ORDER BY e.published DESC
        LIMIT 30"""
    rows = db.engine.execute(sql, user_id)
    for row in rows:
        entry = {
            'id': row.id,
            'title': row.title,
            'site': row.site_url,
            'intro': strip_html_tags(row.content).strip(),  # TODO: tao intro ngay khi update feed
            'unread': row.unread,
            'stared': row.stared,
        }
        headline_list.append(entry)
    return jsonify(count=len(headline_list), objects=headline_list)


@app.route('/api/entry/<int:user_entry_id>', methods=['POST'])
def get_entries(user_entry_id):
    if current_user.is_authenticated() is False:
        return make_error(gettext('Unauthorized!'), 401, 401)

    user_id = current_user.id

    sql = """SELECT
            ue.id, e.title, e.link, f.site_url, e.content,
            e.published, e.author, e.comments, ue.unread, ue.stared, ue.note
        FROM user_entry AS ue
        INNER JOIN entry AS e ON e.id = ue.entry_id
        INNER JOIN feed AS f ON f.id = e.feed_id
        WHERE ue.user_id = %s
        AND ue.id = %s
        LIMIT 1""" % (user_id, user_entry_id)
    logger.debug(sql)
    rows = db.engine.execute(sql)
    for row in rows:
        print row
        entry = {
            'id': row.id,
            'title': row.title,
            'site': row.site_url,
            'link': row.link,
            'content': row.content,
            'published': row.published,
            'author': row.author,
            'comments': row.comments,
            'unread': row.unread,
            'stared': row.stared,
            'note': row.note,
        }
        return jsonify(objects=entry)
    return make_error(gettext('Entry not found'), 404)

