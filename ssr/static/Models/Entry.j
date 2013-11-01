@import <Foundation/CPObject.j>

@implementation Entry : WLRemoteObject
{
    int id @accessors;
    CPString title @accessors;
    CPString link @accessors;
    CPString site @accessors;
    CPString content @accessors;
    CPDate published @accessors;
    CPString author @accessors;
    CPString comments @accessors;
    BOOL unread @accessors;
    BOOL stared @accessors;
    CPString note @accessors;
    int category @accessors;
    int feed @accessors;
}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'id'],
        ['title'],
        ['link'],
        ['site'],
        ['content'],
        ['published'],
        ['author'],
        ['comments'],
        ['unread'],
        ['stared'],
        ['category'],
        ['feed']
    ];
}

- (CPString)remotePath
{
    var path = @"/api/entry/";

    if ([self pk])
        path += [self pk];

    return path
}

- (id)init
{
    if (self = [super init])
    {
        title = @"";
        link = @"";
        site = @"";
        content =@"";
        published = nil;
        author = @"";
        comments = @"";
        unread = 1;
        stared = 0;
        category = -1;
        feed = -1;

    }
    return self;
}

- (CPString)description
{
    return [self UID] + " " + [self pk] + " " + [self name];
}

+ (BOOL)automaticallyLoadsRemoteObjectsForUser
{
    return YES;
}

- (id)initWithJson:(id)obj
{
    if (self  = [super init])
    {
        [self setId:obj.id];
        [self setTitle:obj.title];
        [self setLink:obj.link];
        [self setSite:obj.site];
        [self setContent:obj.content];
        [self setPublished:[[CPDate alloc] initWithTimeIntervalSince1970:obj.published]];
        [self setAuthor:obj.author];
        [self setComments:obj.comments];
        [self setUnread:obj.unread];
        [self setStared:obj.stared];
        [self setNote:obj.note];
        [self setCategory:obj.category_id];
        [self setFeed:obj.feed_id];
    }
    return self;
}
@end
