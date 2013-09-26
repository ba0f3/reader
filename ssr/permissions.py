from flask.ext.principal import Principal, Permission, RoleNeed
from ssr import app


principals = Principal(app)


class roles():
    admin = Permission(RoleNeed('admin'))

