from . import BaseManager, CategoryUnreadCacheRepository
from flask.ext.security import current_user
from ssr.models import Category


class CategoryRepository(BaseManager):
    @staticmethod
    def create(*args):
        category = Category(*args)
        CategoryRepository.save(category)

        CategoryUnreadCacheRepository.create(current_user.id, category.id)

        return category