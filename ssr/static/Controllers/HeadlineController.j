@import "../Constants.j"
@import "../ServerConnection.j"
@import "../Models/Headline.j"


var path = @"/api/headlines",
	headlineControllerSharedInstance;
@implementation HeadlineController : CPArrayController
{
	int selectedCategory;
	int selectedFeed;
}

+ (HeadlineController)sharedHeadlineController
{
    if (headlineControllerSharedInstance == nil)
    {
        headlineControllerSharedInstance = [[HeadlineController alloc] init];
    }
    return headlineControllerSharedInstance;
}

- (id)init
{
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(onCategorySelected:) name:NOTIFICATION_CATEGORY_SELECTED object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(onFeedSelected:) name:NOTIFICATION_FEED_SELECTED object:nil];

	self = [super init];
	if(self)
	{
		selectedCategory = 0;
		selectedFeed = 0
	}
	return self;
}

- (void)onCategorySelected:(CPNotification)notification
{
    CPLog('HeadlineController.onCategorySelected:%@', notification);
}

- (void)onFeedSelected:(CPNotification)notification
{
    CPLog('HeadlineController.onFeedSelected:%@', notification);
}

- (void)loadHeadlines
{
	[[ServerConnection alloc] postJSON:path withObject:nil setDelegate:self];
}

- (int)count
{
	return [[self arrangedObjects] count];
}

- (id)objectAtIndex:(int)rowIndex
{
	return [[self arrangedObjects] objectAtIndex:rowIndex];
}

-(void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
	CPLog('HeadlineController.connection:%@ didReceiveData:%@', connection, '[HIDDEN]');

	var headlines = [CPMutableArray array];

	data = JSON.parse(data);
	for (var i = 0; i < data.count; i++) {
		var headline = [[Headline alloc] initFromObject:data.objects[i]];
		[self addObject:headline];
	}
	[[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HEADLINE_LOADED object:nil];
}
@end
