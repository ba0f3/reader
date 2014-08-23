@import "../Constants.j"
@import "../LocalSetting.j"
@import "../ServerConnection.j"
@import "../Models/Headline.j"


var resourcePath = @"/api/headline/",
    headlineControllerSharedInstance;

RSSHeadlineOrderByNewestFirst = 1;
RSSHeadlineOrderByOldestFirst = 2;

RSSHeadlineNoFilter = 0;
RSSHeadlineFilterByStared = 1;
RSSHeadlineFilterByUnread = 2;
RSSHeadlineFilterByArchives = 3;

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
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(onSpecialFolderSelected:) name:NOTIFICATION_SPECIAL_FOLDER_SELECTED object:nil];
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(onCategorySelected:) name:NOTIFICATION_CATEGORY_SELECTED object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(onCategorySelected:) name:NOTIFICATION_CATEGORY_SELECTED object:nil];
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(onFeedSelected:) name:NOTIFICATION_FEED_SELECTED object:nil];

    self = [super init];
    if (self)
    {
        [self reset];
    }
    return self;
}

- (void)onSpecialFolderSelected:(CPNotification)notification
{
    [self reset];
    var mode = [notification object];

    if (mode == 'unread')
        [LocalSetting setObject:RSSHeadlineFilterByUnread forKey:@"filterMode"];
    else if (mode == 'starred')
        [LocalSetting setObject:RSSHeadlineFilterByStared forKey:@"filterMode"];
    else if (mode == 'archives')
        [LocalSetting setObject:RSSHeadlineFilterByArchives forKey:@"filterMode"];
    else
        [LocalSetting setObject:RSSHeadlineNoFilter forKey:@"filterMode"];
    [self fetchHeadlines];
}

- (void)onCategorySelected:(CPNotification)notification
{
    CPLog('HeadlineController.onCategorySelected:%@', notification);
    [self reset];
    selectedCategory = [[notification object] pk];
    [self fetchHeadlines];
}

- (void)onFeedSelected:(CPNotification)notification
{
    CPLog('HeadlineController.onFeedSelected:%@', notification);
    [self reset];
    selectedFeed = [[notification object] pk];
    [self fetchHeadlines];
}

- (void)reset
{
    [self setContent:[CPArray array]];
    selectedCategory = -1;
    selectedFeed = -1;
    lastTimestamp = -1;
    isPrefetching = NO;
    noMoreResult = NO;

}

- (void)fetchHeadlines
{

    var querystring = new Array;
    querystring.push('orderMode=' + [LocalSetting get:@"orderMode"] || RSSHeadlineOrderByNewestFirst);
    querystring.push('filterMode=' + [LocalSetting get:@"filterMode"] || RSSHeadlineFilterByUnread);
    if (lastTimestamp > 0)
        querystring.push('lastTimestamp=' + lastTimestamp);
    if (selectedFeed > 0)
        querystring.push('feed=' + selectedFeed);
    if (selectedCategory > 0)
        querystring.push('category=' + selectedCategory);

    var path = resourcePath + '?' + querystring.join('&');

    [WLRemoteAction schedule:WLRemoteActionGetType path:path delegate:self message:"Loading headlines"];
}

- (void)remoteActionDidFinish:(WLRemoteAction)anAction
{
    var headlines = [Headline objectsFromJson:[anAction result].objects];

    // last response return less then 20 article => no more article to load
    if ([headlines count] < 20)
        noMoreResult = YES;

    lastTimestamp = [[[headlines lastObject] created] timeIntervalSince1970];

    [self addObjects:headlines]
    var headlines = [CPMutableArray array];

    if (isPrefetching)
        isPrefetching = NO; // release lock

    [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HEADLINE_LOADED object:nil];
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
        [self fetchHeadlines];
    }
}

- (void)applyFilters
{
    lastTimestamp = 0;
    isPrefetching = NO;
    noMoreResult = NO;
    [self setContent:[CPArray array]];

    [self fetchHeadlines];

}
@end
