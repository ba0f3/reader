@import "../Constants.j"
@import "../ServerConnection.j"
@import "../Models/Headline.j"


var path = @"/api/headlines"
@implementation HeadlineController : CPObject
{
}

- (id)init
{
	self = [super init];
	if(self)
	{
		[self loadHeadlines];
	}
	return self;
}

- (void)loadHeadlines
{
	[ServerConnection get:path setDelegate:self];
}

-(void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
	CPLog('connection:%@ didReceiveData:%@', connection, data);

	var headlines = [CPMutableArray array];

	data = JSON.parse(data);
	for (var i = 0; i < data.count; i++) {
		var headline = [[Headline alloc] initFromObject:data.objects[i]];
		[headlines addObject:headline];
	}
	[[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HEADLINE_LOADED object:headlines];
}
@end
