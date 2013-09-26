#!/usr/bin/python

from flask import Flask
from flask.ext.sqlalchemy import SQLAlchemy
from flask.ext.script import Manager
from flask.ext.migrate import Migrate, MigrateCommand
from flask.ext.restless import APIManager
from flask.ext.login import LoginManager



import ssr.configs

app = Flask(__name__)

app.config['SECRET_KEY'] = ssr.configs.SECRET_KEY
app.config['DEBUG'] = ssr.configs.DEBUG
app.config['SQLALCHEMY_DATABASE_URI'] = ssr.configs.DATABASE_URI

login_manager = LoginManager()
login_manager.init_app(app)


@login_manager.user_loader
def load_user(uid):
    user = User()
    return user.get(uid)


db = SQLAlchemy(app)
migrate = Migrate(app, db)

from ssr.commands import *

manager = Manager(app)
manager.add_command('db', MigrateCommand)
manager.add_command('demo', InsertDemoDataCommand())
manager.add_command('test', TestRssClient())


import ssr.views
from ssr.models import *

# Create the Flask-Restless API manager.
api_manager = APIManager(app, flask_sqlalchemy_db=db)

# Create API endpoints, which will be available at /api/<tablename> by
# default. Allowed HTTP methods can be specified as well.
api_manager.create_api(Category, methods=['GET', 'POST', 'DELETE'])
api_manager.create_api(Feed, methods=['GET'])






if __name__ == '__main__':
    app.run()
