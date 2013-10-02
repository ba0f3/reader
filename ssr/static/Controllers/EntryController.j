@import "../Constants.j"
@import "../ServerConnection.j"
@import "../Models/Entry.j"

var path = @"/api/entry/%s"
@implementation EntryController : CPObject
{
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
	[ServerConnection get:[CPString stringWithFormat:path,entryId] setDelegate:self];
}

-(void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
	CPLog('connection:%@ didReceiveData:%@', connection, data);

	var entries = [CPMutableArray array];

	data = JSON.parse(data);
	var entry = [[Entry alloc] initFromObject:data.objects];
	[[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENTRY_LOADED object:entry];
}
@end
