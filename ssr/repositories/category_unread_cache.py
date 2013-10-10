from . import BaseManager
from ssr.models import Category, CategoryUnreadCache

class CategoryUnreadCacheRepository(BaseManager):
    @staticmethod
    def create(*args):
        cuc = CategoryUnreadCache(args)

        CategoryUnreadCacheRepository.save(cuc)

        return cuc
