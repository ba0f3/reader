from functools import wraps

from flask_security import login_required

from .. import factory


def create_app(settings_override=None):
    app = factory.create_app(__name__, __path__, settings_override)

    return app


def route(bp, *args, **kwargs):
    def decorator(f):
        @bp.route(*args, **kwargs)
        @login_required
        @wraps(f)
        def wrapper(*args, **kwargs):
            return f(*args, **kwargs)
        return f

    return decorator