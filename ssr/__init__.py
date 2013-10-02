#!/usr/bin/python

from flask import Flask
from flask.ext.sqlalchemy import SQLAlchemy
from flask.ext.script import Manager
from flask.ext.migrate import Migrate, MigrateCommand
from flask.ext.restless import APIManager
from flask.ext.login import LoginManager
import logging
import ssr.configs
import socket

app = Flask(__name__)

logger = logging.getLogger(__name__)
logger.addHandler(logging.StreamHandler())
logger.addHandler(logging.FileHandler('/tmp/dodareader.log'))
if ssr.configs.DEBUG:
    logger.setLevel(logging.DEBUG)
else:
    logger.setLevel(logging.INFO)

app.config['SECRET_KEY'] = ssr.configs.SECRET_KEY
app.config['DEBUG'] = ssr.configs.DEBUG
app.config['SQLALCHEMY_DATABASE_URI'] = ssr.configs.DATABASE_URI

login_manager = LoginManager()
login_manager.init_app(app)


# default timeout is 3 mins
socket.setdefaulttimeout(180)

@login_manager.user_loader
def load_user(uid):
    logger.debug("load_user: %s", uid)
    return User.query.get(uid)


db = SQLAlchemy(app)
migrate = Migrate(app, db)

from ssr.cron import scheduler
from ssr.commands import *

manager = Manager(app)
manager.add_command('db', MigrateCommand)
manager.add_command('update', UpdateCommand)
manager.add_command('dev', DevelCommand)


import ssr.views
from ssr.models import *

# Create the Flask-Restless API manager.
api_manager = APIManager(app, flask_sqlalchemy_db=db)

# Create API endpoints, which will be available at /api/<tablename> by
# default. Allowed HTTP methods can be specified as well.
api_manager.create_api(Category, methods=['GET', 'POST', 'DELETE'])
api_manager.create_api(UserEntry, methods=['GET'])


if __name__ == '__main__':
    app.run()
