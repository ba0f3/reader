from . import BaseManager, CategoryUnreadCacheRepository
from flask.ext.security import current_user
from ssr.models import Category


class CategoryRepository(BaseManager):
    @staticmethod
    def create(*args):
        category = Category(*args)
        CategoryRepository.save(category)

        CategoryUnreadCacheRepository.create(category.id, current_user.id)

        return category