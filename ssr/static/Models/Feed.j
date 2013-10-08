@import "../Constants.j"

@implementation Feed : CPObject
{
    int id @accessors;
    CPString name @accessors;
    CPString site @accessors;
    int order @accessors;
    int unread @accessors;
}

- (id)initFromObject:(Object)obj
{
    if (self  = [super init])
    {
        [self setId:obj.id];
        [self setName:obj.name];
        [self setSite:obj.site];
        [self setOrder:obj.order_id];
        [self setUnread:obj.unread];
    }
    return self
}

- (void)decreaseUnread
{
    [self decreaseUnreadByValue:1];
}

- (void)decreaseUnreadByValue:(int)value
{
    unread-= value;
    [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ITEM_UNREAD_UPDATED object:self];
}

@end
