from flask import *
from ssr import app, db, logger

from flask.ext.login import login_required, login_user, logout_user, current_user
from ssr.models import User
from ssr.helpers import strip_html_tags

@app.route('/')
@login_required
def index():
    template = 'index-debug.html' if app.debug is True else 'index.html'
    return render_template(template, categories=current_user.categories)

@app.route('/login', methods=['GET', 'POST'])
def login():
    error = None
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']

        user = User.query.filter_by(username=username).first()

        if user is None or user.check_password(password) is False:
            error = 'Invalid username or password'
        else:
            login_user(user)
            flash("Logged in successfully.")
            return redirect(request.args.get("return") or url_for('.index'))
    return render_template('login.html', error=error)

@app.route("/logout")
@login_required
def logout():
    logout_user()
    return redirect(url_for('.login'))

@app.route('/api/headlines')
@login_required
def get_headlines():
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
            'intro': strip_html_tags(row.content).strip(), # TODO: tao intro ngay khi update feed
            'unread': row.unread,
            'stared': row.stared,
        }
        headline_list.append(entry)
    return jsonify(count=len(headline_list), objects=headline_list)


@app.route('/api/entry/<int:user_entry_id>')
@login_required
def get_entries(user_entry_id):
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
    abort(404)

