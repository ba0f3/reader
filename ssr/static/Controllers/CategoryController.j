@import "../Constants.j"
@import "../ServerConnection.j"
@import "../Models/Category.j"


var resourcePath = @"/api/category",
    categoryControllerSharedInstance;
@implementation CategoryController : CPObject
{
    CPMutableArray categories @accessors;
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

    categories = [CPMutableArray array];

    return self;
}

- (void)fetchCategories
{
    [WLRemoteAction schedule:WLRemoteActionGetType path:resourcePath delegate:self message:"Loading categories"];
}

- (void)deleteCategory:(id)category
{
    [categories removeObject:category];
    [category ensureDeleted];
}

- (void)remoteActionDidFinish:(WLRemoteAction)anAction
{
    categories = [Category objectsFromJson:[anAction result].objects];
    [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CATEGORY_LOADED object:nil];
}

@end
