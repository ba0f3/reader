__author__ = 'rgv151'

from rwrapper import rwrapper as rwrapper_base
from ...core import rdb
import rethinkdb as r


class rwrapper(rwrapper_base):
    @property
    def _connection(self):
        """Hack to make rethink connection always available"""
        return rdb.conn

    def get(self, o=False, exception=False):
        if o is False:
            o = self.__class__
        return super(rwrapper, self).get(o, exception)

    def save(self):
        # Try and be lazy about saving. Only save if our values have actually
        # changed
        if not self._changed:
            return False

        # Validate any defined fields and set any defaults
        doc = self.__dict__
        if isinstance(self._meta, dict) and len(self._meta) > 0:
            for key in self._meta.keys():
                setattr(self, key, self._meta[key].validate(doc[key]))

                #Check unique
                if hasattr(self._meta[key], 'unique') and getattr(self._meta[key], 'unique'):
                    result = r.table(self._db_table).filter({key: getattr(self, key)}).limit(1).run(self._connection)
                    unique_check_result = True
                    try:
                        (iter(result)).next()
                    except StopIteration:
                        unique_check_result = False
                    if unique_check_result:
                        raise ValueError("%s with value %s exists." % (key, getattr(self, key)))

        # id being none means we should insert
        if self.id is None:
            doc = self.__dict__
            if 'id' in doc:
                del doc['id']
            self.changed(False)
            return self.evaluate_insert(r.table(self._db_table).insert(
                doc,
                upsert=self._upsert
            ).run(self._connection))

        # id found; update
        self.changed(False)
        return self.evaluate_update(r.table(self._db_table).filter({'id': self.id}).update(
            self.__dict__,
            non_atomic=self._non_atomic
        ).run(self._connection))