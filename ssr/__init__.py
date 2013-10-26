#!/usr/bin/python

from flask import Flask, request
from flask.ext.sqlalchemy import SQLAlchemy
from flask.ext.migrate import Migrate
#from flask.ext.restless import APIManager
from flask.ext.security import Security, SQLAlchemyUserDatastore, current_user
from flask.ext.babel import Babel
import logging
import ssr.configs

# Create app
app = Flask(__name__)
app.config['SECRET_KEY'] = ssr.configs.SECRET_KEY
app.config['DEBUG'] = ssr.configs.DEBUG
app.config['SQLALCHEMY_DATABASE_URI'] = ssr.configs.DATABASE_URI
app.config['SQLALCHEMY_ECHO'] = True
app.config['SQLALCHEMY_RECORD_QUERIES'] = True
app.config['SECURITY_FLASH_MESSAGES'] = False
app.config['SECURITY_PASSWORD_HASH'] = 'sha256_crypt'
app.config['SECURITY_PASSWORD_SALT'] = ssr.configs.PASSWORD_SALT
app.config['BABEL_DEFAULT_LOCALE'] = ssr.configs.DEFAULT_LOCALE
app.config['BABEL_DEFAULT_TIMEZONE'] = ssr.configs.DEFAULT_TIMEZONE

logger = logging.getLogger(__name__)
logger.addHandler(logging.StreamHandler())
logger.addHandler(logging.FileHandler('/tmp/dodareader.log'))
if ssr.configs.DEBUG:
    logger.setLevel(logging.DEBUG)
else:
    logger.setLevel(logging.INFO)

# Create database connection object
db = SQLAlchemy(app)

# Setup Flask-Babel
babel = Babel(app)

@babel.localeselector
def get_locale():
    if current_user.is_authenticated():
        return current_user.locale if current_user.locale is not None else None
    return request.accept_languages.best_match(['en', 'vi'])

@babel.timezoneselector
def get_timezone():
    if current_user.is_authenticated():
        return current_user.timezone if current_user.timezone is not None else None

from ssr.cron import scheduler
import ssr.commands
import ssr.views
import ssr.rest
from ssr.models import User, Role


# Flask-Script manager
manager = ssr.commands.manager

# Setup Flask-Security
security = Security(app, SQLAlchemyUserDatastore(db, User, Role))

# Setup Flask-Migrate
Migrate(app, db)


if __name__ == '__main__':
    app.run()
