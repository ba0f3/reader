from flask import *
from ssr import app
from flask.ext.login import login_required, login_user, logout_user, current_user
from ssr.models import User

@app.route('/')
@login_required
def index():
    return render_template('index.html', categories=current_user.categories)

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