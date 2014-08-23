from . import BaseManager
from reader import db
from reader.models import Category, CategoryUnreadCache, FeedUnreadCache

class CategoryUnreadCacheRepository(BaseManager):
    @staticmethod
    def create(*args):
        cuc = CategoryUnreadCache(*args)

        CategoryUnreadCacheRepository.save(cuc)

        return cuc

    @staticmethod
    def update(category_id):
        sql = "UPDATE category_unread_cache AS cuc SET value = \
                (SELECT SUM(fuc.value) FROM feed_unread_cache as fuc \
                INNER JOIN user_feed AS uf on uf.id = fuc.user_feed_id \
                WHERE uf.category_id = %s \
                GROUP BY uf.category_id), last_update = NOW() \
              WHERE cuc.category_id = %s" % (category_id, category_id)

        db.engine.execute(sql)
