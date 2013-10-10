from . import BaseManager, FeedUnreadCacheRepository
from ssr.models import Category
from flask.ext.security import current_user


class UserFeedRepository(BaseManager):
    @staticmethod
    def create(*args):
        uf = Category(args)
        UserFeedRepository.save(uf)

        FeedUnreadCacheRepository.create(uf.id, current_user.id)

        return uf