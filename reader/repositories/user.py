from . import BaseManager
from reader.models import User


class UserRepository(BaseManager):
    @staticmethod
    def create(*args):
        user = User(*args)

        UserRepository.save(user)

        return user