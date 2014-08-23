DEBUG = True
SECRET_KEY = 'hT;GNy/z``05N..Ly==^(cFt!;Dwn=Jl]QtWlHkYu}a4a#?(6KMRw/A=79@$'


SECURITY_FLASH_MESSAGES = False
SECURITY_PASSWORD_HASH = 'sha256_crypt'
SCURITY_PSSWORD_SALT = '$q{F0Ya?Y;DJ&6tk&e4&bfj~6<I@yH?i"DX8=n8c!Gb@0".pDC}Q=H{nZEDf'

FEED_UPDATE_PERIOD = 'hourly' # 'hourly', 'daily', 'weekly', 'monthly', 'yearly'
FEED_UPDATE_FREQUENCY = 1
FEED_UPDATE_TTL = 3

RETHINKDB_HOST = 'localhost'
RETHINKDB_PORT = '28015'
RETHINKDB_AUTH = ''
RETHINKDB_DB = 'reader'

BABEL_DEFAULT_LOCALE = 'en_US'
BAEL_DEFAULT_TIMEZONE = 'Asia/Ho_Chi_Minh'