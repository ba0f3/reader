from flask import Blueprint, render_template

from . import route

bp = Blueprint('index', __name__)


#@route(bp, '/')
@bp.route('/')
def index():
    """Returns the dashboard interface."""
    return render_template('index-debug.html')