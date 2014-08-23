@import "../Constants.j"
@import "Feed.j"

@implementation Category : WLRemoteObject
{
    CPString name @accessors;
    int order @accessors;
    int parent @accessors;
    int unread @accessors;
    CPArray feeds @accessors;

}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'id'],
        ['name'],
        ['order'],
        ['parent'],
        ['unread'],
        ['feeds', 'feeds', [WLForeignObjectsTransformer forObjectClass:Feed]],
    ];
}

- (CPString)remotePath
{
    var path = @"/api/category/";

    if ([self pk])
        path += [self pk];

    return path
}

- (id)init
{
    if (self = [super init])
    {
        name = @"";
        order = 0;
        parent = -1;
        unread = 0;
        feeds = [CPArray array];

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
@end
