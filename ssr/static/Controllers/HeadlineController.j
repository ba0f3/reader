@import "../Constants.j"
@import "../ServerConnection.j"
@import "../Models/Headline.j"


var path = @"/api/headlines",
	headlineControllerSharedInstance;

RSSHeadlineOrderByNewestFirst = 0;
RSSHeadlineOrderByOldestFirst = 1;
RSSHeadlineOrderByTitle = 2;

@implementation HeadlineController : CPArrayController
{
	int selectedCategory;
	int selectedFeed;
	int lastTimestamp;
	int orderMode @accessors;
	BOOL isPrefetching

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
		orderMode = RSSHeadlineOrderByNewestFirst;
		[self reset];
	}
	return self;
}

- (void)onCategorySelected:(CPNotification)notification
{
    CPLog('HeadlineController.onCategorySelected:%@', notification);
    [self reset];
    selectedCategory = [notification object];
    [self loadHeadlines];
}

- (void)onFeedSelected:(CPNotification)notification
{
    CPLog('HeadlineController.onFeedSelected:%@', notification);
    [self reset];
    selectedFeed = [notification object];
    [self loadHeadlines];
}

- (void)reset
{
	[self setContent:[CPArray array]];
	selectedCategory = 0;
	selectedFeed = 0;
	lastTimestamp = 0;
	isPrefetching = NO;

}

- (void)loadHeadlines
{
	var data = {
		'orderMode': orderMode,
		'lastTimestamp': lastTimestamp,
		'feed': selectedFeed,
		'category': selectedCategory
	}
	[[ServerConnection alloc] postJSON:path withObject:data setDelegate:self];
}

- (int)count
{
	return [[self arrangedObjects] count];
}

- (id)objectAtIndex:(int)rowIndex
{
	return [[self arrangedObjects] objectAtIndex:rowIndex];
}

- (void)prefetchHeadlines:(int)rowIndex
{
	if(isPrefetching) return; // a request is in progress, ignore other

	if(rowIndex + 3 >= [self count])
	{
		isPrefetching = YES;
		[self loadHeadlines];
	}
}

-(void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
	CPLog('HeadlineController.connection:%@ didReceiveData:%@', connection, '[HIDDEN]');

	var headlines = [CPMutableArray array];

	data = JSON.parse(data);
	var headline;
	for (var i = 0; i < data.count; i++) {
		headline = [[Headline alloc] initFromObject:data.objects[i]];
		[self addObject:headline];
	}
	lastTimestamp = [[headline created] timeIntervalSince1970];
	delete headline;

	if(isPrefetching) isPrefetching = NO; // release lock

	[[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HEADLINE_LOADED object:nil];
}
@end
