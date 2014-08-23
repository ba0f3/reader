import rethinkdb as r

from flask.ext.security.datastore import Datastore, UserDatastore


class RethinkEngineDatastore(Datastore):
    def put(self, model):
        model.save()
        return model

    def delete(self, model):
        model.delete()
        return model


class RethinkEngineUserDatastore(RethinkEngineDatastore, UserDatastore):
    def __init__(self, db, user_model, role_model):
        RethinkEngineDatastore.__init__(self, db)
        UserDatastore.__init__(self, user_model, role_model)

        self.user_model = user_model
        self.role_model = role_model

    def get_user(self, id_or_email):
        """Returns a user matching the specified ID or email address"""

        # FIXME: this thing is bad, i think!
        if '@' in id_or_email:
            user = self.user_model(email=id_or_email).get()
        else:
            user = self.user_model(username=id_or_email).get()

        return user

    def find_user(self, *args, **kwargs):
        """Returns a user matching the provided parameters."""
        return self.user_model(**kwargs).get()

    def find_role(self, *args, **kwargs):
        """Returns a role matching the provided name."""
        return self.role_model(**kwargs).get()