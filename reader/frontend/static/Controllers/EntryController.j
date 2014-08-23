
@import "../Constants.j"
@import "../ServerConnection.j"
@import "../Models/Entry.j"

var resourcePath = @"/api/entry/",
    entryControllerSharedInstance;
@implementation EntryController : CPObject
{
    CPMutableDictionary _entryCache

}

+ (EntryController)sharedEntryController
{
    if (entryControllerSharedInstance == nil)
    {
        entryControllerSharedInstance = [[EntryController alloc] init];
    }
    return entryControllerSharedInstance;
}

- (Entry)getCachedEntryWithId:(int)entryId
{
    return [_entryCache objectForKey:entryId];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _entryCache = [CPMutableDictionary dictionary];
    }
    return self;
}

- (void)loadEntry:(int)entryId
{
    [self loadEntry:entryId forceReload:NO];
}

- (void)loadEntry:(int)entryId forceReload:(BOOL)forceReload
{
    var path = resourcePath + '/' + entryId;
    if (forceReload)
    {
        [WLRemoteAction schedule:WLRemoteActionGetType path:path delegate:self message:"Loading headlines"];
    }
    else
    {
        if ([_entryCache containsKey:entryId])
        {
            [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENTRY_LOADED object:entryId];
        }
        else
        {
            [WLRemoteAction schedule:WLRemoteActionGetType path:path delegate:self message:"Loading headlines"];
        }
    }
}

- (void)remoteActionDidFinish:(WLRemoteAction)anAction
{
    var entry = [[Entry alloc] initWithJson:[anAction result]];

    [_entryCache setObject:entry forKey:entry.id];

    [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENTRY_LOADED object:entry.id];
}

- (void)markAsRead:(int)entryId
{
}

@end
