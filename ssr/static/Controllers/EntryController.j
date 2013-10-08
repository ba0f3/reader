
@import "../Constants.j"
@import "../ServerConnection.j"
@import "../Models/Entry.j"

var path = @"/api/entry/%s",
	entryCache = {},
	entryControllerSharedInstance;
@implementation EntryController : CPObject
{
}

+ (EntryController)sharedEntryController
{
    if (entryControllerSharedInstance == nil)
    {
        entryControllerSharedInstance = [[EntryController alloc] init];
    }
    return entryControllerSharedInstance;
}

+ (Entry)getCachedEntryWithId:(int)entryId
{
	return entryCache.hasOwnProperty(entryId)?entryCache[entryId]:nil;
}

- (id)init
{
	self = [super init];
	if(self)
	{

	}
	return self;
}

- (void)loadEntry:(int)entryId
{
	[self loadEntry:entryId forceReload:NO];
}

- (void)loadEntry:(int)entryId forceReload:(BOOL)forceReload
{
	if(forceReload)
	{
		[[ServerConnection alloc] postJSON:[CPString stringWithFormat:path,entryId] withObject:nil setDelegate:self];
	}
	else
	{
		if(entryCache.hasOwnProperty(entryId))
	    {
	        [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENTRY_LOADED object:entryId];
	    }
	    else
	    {
	        [[ServerConnection alloc] postJSON:[CPString stringWithFormat:path,entryId] withObject:nil setDelegate:self];
	    }
	}

}

-(void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
	CPLog('connection:%@ didReceiveData:%@', connection, data);
	data = JSON.parse(data);
	var entry = [[Entry alloc] initFromObject:data.objects];

	entryCache[entry.id] = entry;

	[[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENTRY_LOADED object:entry.id];
}
@end
