from flask.ext.script import Manager
from ssr.updater import Updater

UpdateCommand = Manager(usage='Perform database update')
@UpdateCommand.command
def feeds():
    "Update feed entries"
    Updater.feeds()

@UpdateCommand.command
def metadata():
    "Update feed metadata, such as: site url, favicon, update interval"
    Updater.metadata()
