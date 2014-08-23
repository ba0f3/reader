from flask.ext.security import Security
from flask.ext.rethinkdb import RethinkDB
import logging

logger = logging.getLogger(__name__)
logger.addHandler(logging.StreamHandler())
logger.addHandler(logging.FileHandler('/tmp/reader.log'))
logger.setLevel(logging.DEBUG)


rdb = RethinkDB()
# Setup Flask-Security
security = Security()


class ReaderError(Exception):
    """Base application error class."""

    def __init__(self, msg):
        self.msg = msg


class ReaderFormError(Exception):
    """Raise when an error processing a form occurs."""

    def __init__(self, errors=None):
        self.errors = errors