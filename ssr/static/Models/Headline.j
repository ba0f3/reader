@import <Foundation/CPObject.j>

@implementation Headline : WLRemoteObject
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

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'id'],
        ['title'],
        ['site'],
        ['intro'],
        ['created'],
        ['published'],
        ['unread'],
        ['stared']
    ];
}

- (CPString)remotePath
{
    var path = @"/api/headline/";

    if ([self pk])
        path += [self pk];

    return path
}

- (id)init
{
    if (self = [super init])
    {
        title = @"";
        site = @"";
        intro = @"";
        created = nil;
        published = nil;
        unread = 1;
        stared = 0;
    }
    return self;
}

- (id)initWithJson:(id)obj
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

- (CPString)description
{
    return [self UID] + " " + [self pk] + " " + [self title];
}
@end
