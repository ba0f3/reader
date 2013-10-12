from ssr.models import Entry
from . import BaseManager


class EntryRepository(BaseManager):

    @staticmethod
    def create(*args):
        entry = Entry(*args)

        EntryRepository.save(entry)

        return entry