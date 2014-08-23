from . import BaseManager
from reader.models import FeedUnreadCache


class FeedUnreadCacheRepository(BaseManager):
    @staticmethod
    def create(*args):
        fuc = FeedUnreadCache(*args)

        FeedUnreadCacheRepository.save(fuc)

        return fuc
