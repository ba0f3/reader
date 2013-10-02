@import "../Constants.j"
@import "../ServerConnection.j"
@import "../Models/Entry.j"


var path = @"/api/entry"
@implementation EntryController : CPObject
{
}

- (id)init
{
	self = [super init];
	if(self)
	{
		[self loadEntries];
	}
	return self;
}

- (void)loadEntries
{
	[ServerConnection get:path setDelegate:self];
}

-(void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
	CPLog('connection:%@ didReceiveData:%@', connection, data);

	var entries = [CPMutableArray array];

	data = JSON.parse(data);
	for (var i = 0; i < data.count; i++) {
		var entry = [[Entry alloc] initFromObject:data.objects[i]];
		[entries addObject:entry];
	}
	[[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENTRY_LOADED object:entries];
}
@end
