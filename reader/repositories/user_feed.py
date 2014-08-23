from . import BaseManager, FeedUnreadCacheRepository
from reader.models import UserFeed
from flask.ext.security import current_user


class UserFeedRepository(BaseManager):
    @staticmethod
    def create(*args):
        uf = UserFeed(*args)
        UserFeedRepository.save(uf)

        FeedUnreadCacheRepository.create(current_user.id, uf.id)

        return uf