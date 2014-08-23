import pytz
from rwrapper.fields import *
from flask import current_app
from validate_email import validate_email

__all__ = ('Field', 'CharField', 'LongField', 'IntegerField', 'FloatField', 'ObjectField',
           'DateTimeField', 'EmailField')


class DateTimeField(Field):
    auto_now_add = False
    auto_now = False

    def validate(self, value):
        if self.auto_now:
            from datetime import datetime

            value = datetime.now(pytz.timezone(current_app.config.get('BABEL_DEFAULT_TIMEZONE')))
        elif self.auto_now_add and not value:
            from datetime import datetime

            value = datetime.now(pytz.timezone(current_app.config.get('BABEL_DEFAULT_TIMEZONE')))
        value = super(DateTimeField, self).validate(value)
        if value is not None:
            try:
                if not value.tzinfo:
                    value = pytz.timezone(current_app.config.get('BABEL_DEFAULT_TIMEZONE')).localize(value)
            except:
                raise ValueError('%s field is not datetime type. Found type: %s' % (
                    self._name(),
                    type(value))
                )
        return value


class EmailField(CharField):
    def validate(self, value):
        value = super(EmailField, self).validate(value)
        is_valid = validate_email(value)
        if not is_valid:
            raise ValueError('Value of field is not valid email. %s' % value)
        return value

