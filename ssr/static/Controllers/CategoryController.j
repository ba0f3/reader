@import "../Constants.j"
@import "../ServerConnection.j"
@import "../Models/Category.j"


var path = @"/api/category"
@implementation CategoryController : CPObject
{
}

- (id)init
{
	self = [super init];
	if(self)
	{
		[self loadCategories];
	}
	return self;
}

- (void)loadCategories
{
	[ServerConnection get:path setDelegate:self];
}

-(void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
	CPLog('connection:%@ didReceiveData:%@', connection, data);

	var categories = [CPMutableArray array];

	data = JSON.parse(data);
	for (var i = 0; i < data.objects.length; i++) {
		var category = [[Category alloc] initFromObject:data.objects[i]];
		[categories addObject:category];
	}
	[[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CATEGORY_LOADED object:categories];
}
@end
