@import "../Constants.j"
@import "../ServerConnection.j"
@import "../Models/Category.j"


var categoryCollectionPath = @"/api/categories",
    categoryPath = @"/api/category",
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

- (void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{

    data = JSON.parse(data);
    if (data.load)
    {
        [self handleCategoriesResponse:data];
    }
    else if (data.create)
    {
        [self handleCreateResponse:data];
    }
    else if (data.delete)
    {
        [self handleDeleteResponse:data];
    }
    else if (data.rename)
    {
        [self handleRenameResponse:data];
    }
}

- (void)loadCategories
{
    [[ServerConnection alloc] postJSON:categoryCollectionPath withObject:nil setDelegate:self];
}

- (void)handleCategoriesResponse:(id)data
{
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
        var index = [categories indexOfObject:category];
        [_categoryMap setValue:index forKey:'id_' + [category id]];
    }

    [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CATEGORY_LOADED object:nil];
}

- (void)createCategoryWithName:(CPString)name
{
    var data = new Object;
    data.action = 'create';
    data.name = name
    [[ServerConnection alloc] postJSON:categoryPath withObject:data setDelegate:self];

}

- (void)handleCreateResponse:(id)data
{
    var category = [[Category alloc] initFromObject:data.category];
    [categories addObject:category];
    var index = [categories indexOfObject:category];
    [_categoryMap setValue:index forKey:'id_' + [category id]];
    [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CATEGORY_LOADED object:nil];
}

- (void)updateCategory:(id)category withNewName:(CPString)newName
{
    if (newName == '')
        return;

    var data = new Object;
    data.action = 'rename';
    data.id = [category id];
    data.name = newName;
    [[ServerConnection alloc] postJSON:categoryPath withObject:data setDelegate:self];
}

- (void)handleRenameResponse:(id)data
{
    var cid = data.id,
        category = [self getCategoryById:cid];
    [category setName:data.name];
    [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CATEGORY_LOADED object:nil];
}

- (void)deleteCategoryWithId:(int)categoryId
{
    var data = new Object;
    data.action = 'delete';
    data.id = categoryId
    [[ServerConnection alloc] postJSON:categoryPath withObject:data setDelegate:self];
}

- (void)handleDeleteResponse:(id)data
{
    var cid = data.id;
    [categories removeObject:[self getCategoryById:cid]];
    [_categoryMap removeObjectForKey:'id_' + cid];
    [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CATEGORY_LOADED object:nil];
}

- (Category)getCategoryById:(int)_id
{
    var index = [_categoryMap valueForKey:'id_' + _id];
    return [categories objectAtIndex:index];
}
@end
