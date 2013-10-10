from . import BaseManager
from ssr.models import Feed


class FeedRepository(BaseManager):
    @staticmethod
    def create(*args):
        feed = Feed(args)

        FeedRepository.save(feed)

        return feed