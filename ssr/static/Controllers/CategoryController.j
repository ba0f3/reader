@import "../Constants.j"
@import "../ServerConnection.j"
@import "../Models/Category.j"


var path = @"/api/categories",
    categoryControllerSharedInstance;
@implementation CategoryController : CPObject
{
    CPMutableArray categories @accessors(readonly);
    CPMutableDictionary _categoryMap;
}

+ (CategoryController)sharedCategoryController
{
    if (categoryControllerSharedInstance == nil)
    {
        categoryControllerSharedInstance = [[CategoryController alloc] init];
    }
    return categoryControllerSharedInstance;
}


- (id)init
{
    self = [super init];
    if (self)
    {
        categories = [CPMutableArray array];
        _categoryMap = [CPMutableDictionary dictionary];
    }
    return self;
}

- (void)loadCategories
{
    [[ServerConnection alloc] postJSON:path withObject:nil setDelegate:self];
}

- (void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
    CPLog('CategoryController.connection:%@ didReceiveData:%@', connection, '[HIDDEN]');

    data = JSON.parse(data);
    var feed_arrays = [];

    for (var i = 0; i < data.feeds.length; i++)
    {
        var catid = data.feeds[i].category_id;

        if (feed_arrays[catid] == undefined)
        {
            feed_arrays[catid] = [];
        }
        var feed = [[Feed alloc] initFromObject:data.feeds[i]];
        feed_arrays[catid].push(feed);
    }

    for (var i = 0; i < data.categories.length; i++)
    {
        var catid = data.categories[i].id;
        data.categories[i].feeds = feed_arrays[catid];
        var category = [[Category alloc] initFromObject:data.categories[i]];

        [categories addObject:category];
        var index = [categories count] - 1;
        [_categoryMap setValue:index forKey:'id_' + [category id]];
    }

    [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CATEGORY_LOADED object:nil];
}

- (Category)getCategoryById:(int)_id
{
    var index = [_categoryMap valueForKey:'id_' + _id];
    return [categories objectAtIndex:index];
}
@end
