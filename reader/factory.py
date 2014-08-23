from flask import Flask
from .core import rdb, security
from .datastore import RethinkEngineUserDatastore
from .helpers import register_blueprints
from .models import User, Role


def create_app(package_name, package_path, settings_override=None, register_security_blueprint=True):
    app = Flask(package_name, instance_relative_config=True)

    app.config.from_object('reader.settings')
    app.config.from_pyfile('settings.cfg', silent=True)
    app.config.from_object(settings_override)


    rdb.init_app(app)

    security.init_app(app, RethinkEngineUserDatastore(rdb, User, Role))

    register_blueprints(app, package_name, package_path)

    return app