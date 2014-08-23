@import "../Constants.j"

var feedPath = @"/api/feed",
    feedControllerSharedInstance;


@implementation FeedController : CPObject
{

}

+ (FeedController)sharedFeedController
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
    if (data.subscribe)
    {
        [self handleSubscribeResponse:data];
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

- (void)subscribeFeedWithUrl:(CPString)url setCategory:(int)cid
{
    var data = new Object;
    data.action = 'subscribe';
    data.url = url;
    data.cid = cid;
    [[ServerConnection alloc] postJSON:feedPath withObject:data setDelegate:self];
}

- (void)handleSubscribeResponse:(id)data
{
    if (data.error)
    {
        if (data.error == 401)
            [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FEED_AUTH_REQUIRED object:nil];
        else
        {
            var alert = [CPAlert alertWithError:@"Unable to subscribe this feed"];
            [alert setInformativeText:data.message];
            [alert runModal];
        }
    }
    else
    {
        var feed = [[Feed alloc] initFromObject:data.feed],
            category = [[CategoryController sharedCategoryController] getCategoryById:data.feed.category_id];
        [category addFeed:feed];
        [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FEED_DIALOG_SHOULD_CLOSE object:nil];
        [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CATEGORY_LOADED object:nil];
    }
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


- (void)findFeed:(CPString)url
{
    var data = new Object;
    data.url = url;
    [[ServerConnection alloc] get:feedPath withObject:data setDelegate:self];
}
@end
