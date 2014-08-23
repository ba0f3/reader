from flask import Blueprint, jsonify
from flask.ext.security import current_user
from ..utils import make_error

from . import route


bp = Blueprint('session', __name__,)

@bp.route('/openSession', methods=['POST'])
def open_session():
    if current_user.is_authenticated():
        return jsonify(open=True, user=current_user.get_profile())
    else:
        return make_error('Unauthorized!', 401, 401)
