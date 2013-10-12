@import "../Constants.j"
@import "../LocalSetting.j"
@import "../ServerConnection.j"
@import "../Models/Headline.j"


var path = @"/api/headlines",
    headlineControllerSharedInstance;

RSSHeadlineOrderByNewestFirst = 1;
RSSHeadlineOrderByOldestFirst = 2;
RSSHeadlineOrderByTitle = 3;

RSSHeadlineNoFilter = 1;
RSSHeadlineFilterByStared = 2;
RSSHeadlineFilterByUnread = 3;
RSSHeadlineFilterByUnreadFirst = 4;

@implementation HeadlineController : CPArrayController
{
    int selectedCategory;
    int selectedFeed;
    int lastTimestamp;
    BOOL isPrefetching;
    BOOL noMoreResult;

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
    if (self)
    {
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
    noMoreResult = NO;

}

- (void)loadHeadlines
{
    if (noMoreResult)
        return; // end of table, no more to load
    var data = new Object;
    data.orderMode = [LocalSetting get:@"orderMode"] || RSSHeadlineOrderByNewestFirst;
    data.filterMode = [LocalSetting get:@"filterMode"] || RSSHeadlineFilterByUnread;
    data.lastTimestamp = lastTimestamp;
    data.feed = selectedFeed;
    data.category = selectedCategory;

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
    if (noMoreResult)
        return; // end of table, no more to load
    if (isPrefetching)
        return; // a request is in progress, ignore other

    if (rowIndex + 3 >= [self count])
    {
        isPrefetching = YES;
        [self loadHeadlines];
    }
}

- (void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
    CPLog('HeadlineController.connection:%@ didReceiveData:%@', connection, '[HIDDEN]');

    var headlines = [CPMutableArray array];

    data = JSON.parse(data);

    // last response return less then 20 article => no more article to load
    if (data.count < 20)
        noMoreResult = YES;

    var headline;
    for (var i = 0; i < data.count; i++)
    {
        headline = [[Headline alloc] initFromObject:data.objects[i]];
        [self addObject:headline];
    }
    lastTimestamp = [[headline created] timeIntervalSince1970];
    delete headline;

    if (isPrefetching)
        isPrefetching = NO; // release lock

    [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HEADLINE_LOADED object:nil];
}

- (void)applyFilters
{
    lastTimestamp = 0;
    isPrefetching = NO;
    noMoreResult = NO;
    [self setContent:[CPArray array]];

    [self loadHeadlines];

}
@end
