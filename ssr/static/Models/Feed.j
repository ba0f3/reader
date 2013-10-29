@import "../Constants.j"

@implementation Feed : WLRemoteObject
{
    int id @accessors;
    CPString name @accessors;
    CPString site @accessors;
    int order @accessors;
    int unread @accessors;
}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'id'],
        ['name'],
        ['site'],
        ['order'],
        ['unread']
    ];
}


- (id)init
{
    if (self = [super init])
    {
    }
    return self;
}

- (CPString)description
{
    return [self UID] + " " + [self pk] + " " + [self name];
}
@end
