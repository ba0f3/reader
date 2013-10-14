var feedPath = @"/api/feed",
    feedControllerSharedInstance;


@implementation FeedController : CPObject
{

}

+ (FeedController)sharedCategoryController
{
    if (feedControllerSharedInstance == nil)
    {
        feedControllerSharedInstance = [[FeedController alloc] init];
    }
    return feedControllerSharedInstance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{

    data = JSON.parse(data);
    if (data.create)
    {
        [self handleCreateResponse:data];
    }
    else if (data.edit)
    {
        [self handleRenameResponse:data];
    }
    else if (data.unsubscribe)
    {
        [self handleUnsubscribeResponse:data];
    }
}

- (void)subscribeFeedWithUrl:(CPString)url
{
    var data = new Object;
    data.action = 'subscribe';
    data.url = url
    [[ServerConnection alloc] postJSON:feedPath withObject:data setDelegate:self];
}

- (void)handleCreateResponse:(id)data
{

}

- (void)unsubscribeFeedWithId:(int)feedId
{
    var data = new Object;
    data.action = 'unsubscribe';
    data.id = feedId
    [[ServerConnection alloc] postJSON:feedPath withObject:data setDelegate:self];
}

- (void)handleUnsubscribeResponse:(id)data
{
    var sharedCategoryController = [CategoryController sharedCategoryController],
        cid = data.cid,
        fid = data.fid,
        category = [sharedCategoryController getCategoryById:cid],
        feed = [category getFeedById:fid];
    [[category feeds] removeObject:feed];
    [category updateUnreadCount];

    [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CATEGORY_LOADED object:nil];
}

@end
