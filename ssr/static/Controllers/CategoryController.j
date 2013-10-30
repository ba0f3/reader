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

- (void)createCategoryWithName:(CPString)name
{
    var category = [[Category alloc] init];
    [category setName:name];
    [category create];

    [categories addObject:category];

    [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CATEGORY_LOADED object:nil];

}

- (void)updateCategory:(id)category withNewName:(CPString)name
{
    [category setName:name];
    [category ensureSaved];

    [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CATEGORY_LOADED object:nil];
}

- (void)deleteCategory:(id)category
{
    [categories removeObject:category];
    [category delete];
    [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CATEGORY_LOADED object:nil];
}

- (void)remoteActionDidFinish:(WLRemoteAction)anAction
{
    categories = [Category objectsFromJson:[anAction result].objects];
    [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CATEGORY_LOADED object:nil];
}

@end
