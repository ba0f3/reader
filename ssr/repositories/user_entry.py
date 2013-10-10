from . import BaseManager
from ssr.models import UserEntry, CategoryUnreadCache, FeedUnreadCache


class UserEntryRepository(BaseManager):

    @staticmethod
    def Create(*args):
        ue = UserEntry(args)
        UserEntryRepository.save(ue)

        if ue.unread:
            fuc = FeedUnreadCache.query.filter_by(user_feed_id=ue.user_feed_id).first()
            fuc.inrease(1)
            cuc = CategoryUnreadCache.query.filter_by(category_id=ue.user_feed.category_id).first()
            cuc.inrease(1)

            BaseManager.save(fuc, cuc)
        return ue

    @staticmethod
    def markAsRead(id):
        ue = UserEntry.query.get(id)
        if not ue:
            return 404

        if ue.unread is False:
            return 304

        ue.unread = False

        fuc = FeedUnreadCache.query.filter_by(user_feed_id=ue.user_feed_id).first()
        fuc.decrease(1)

        cuc = CategoryUnreadCache.query.filter_by(category_id=ue.user_feed.category_id).first()
        cuc.decrease(1)

        UserEntryRepository.save(ue, fuc, cuc)

        return 200

    @staticmethod
    def markAsUnread(id):
        ue = UserEntry.query.get(id)
        if not ue:
            return 404

        if ue.unread is True:
            return 304

        ue.unread = True

        fuc = FeedUnreadCache.query.filter_by(user_feed_id=ue.user_feed_id).first()
        fuc.inrease(1)

        cuc = CategoryUnreadCache.query.filter_by(category_id=ue.user_feed.category_id).first()
        cuc.inrease(1)

        UserEntryRepository.save(ue, fuc, cuc)
        return 200

    @staticmethod
    def markAsFavorite(id):
        ue = UserEntry.query.get(id)
        if not ue:
            return 404

        if ue.stared is True:
            return 304

        ue.stared = True

        UserEntryRepository.save(ue)

        return 200

    @staticmethod
    def unmarkAsFavorite(id):
        ue = UserEntry.query.get(id)
        if not ue:
            return 404

        if ue.stared is False:
            return 304

        ue.stared = False
        UserEntryRepository.save(ue)

        return 200
