from flask.ext.script import Manager
from flask.ext.migrate import MigrateCommand
from reader import app
from dev import DevelCommand
from update import UpdateCommand


manager = Manager(app)
manager.add_command('db', MigrateCommand)
manager.add_command('dev', DevelCommand)
manager.add_command('update', UpdateCommand)