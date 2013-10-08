@import <Foundation/CPObject.j>

@implementation Headline : CPObject
{
    int id @accessors;
    CPString title @accessors;
    CPString site @accessors;
    CPString intro @accessors;
    CPDate created @accessors;
    CPDate published @accessors;
    BOOL unread @accessors;
    BOOL stared @accessors;
}
- (id)initFromObject:(Object)obj
{
    if (self  = [super init])
    {
        [self setId:obj.id];
        [self setTitle:obj.title];
        [self setSite:obj.site];
        [self setIntro:obj.intro];
        [self setCreated:[[CPDate alloc] initWithTimeIntervalSince1970:obj.created]];
        [self setPublished:[[CPDate alloc] initWithTimeIntervalSince1970:obj.published]];
        [self setUnread:obj.unread];
        [self setStared:obj.stared];
    }
    return self;
}
@end
