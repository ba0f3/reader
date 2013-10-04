@import "../Constants.j"
@import "../ServerConnection.j"
@import "../Models/Category.j"


var path = @"/api/categories"
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
	[[ServerConnection alloc] postJSON:path withObject:nil setDelegate:self];
}

-(void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
	CPLog('CategoryController.connection:%@ didReceiveData:%@', connection, '[HIDDEN]');

	var categories = [CPMutableArray array];

	data = JSON.parse(data);
	var feed_arrays = [];

	for (var i = 0; i < data.feeds.length; i++) {
		var catid = data.feeds[i].category_id;

		if(feed_arrays[catid] == undefined)
		{
			feed_arrays[catid] = [];
		}
		var feed = [[Feed alloc] initFromObject:data.feeds[i]];
		feed_arrays[catid].push(feed);
	}

	for (var i = 0; i < data.categories.length; i++) {
		var catid = data.categories[i].id;
		data.categories[i].feeds = feed_arrays[catid];
		var category = [[Category alloc] initFromObject:data.categories[i]];
		[categories addObject:category];
	}
	[[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CATEGORY_LOADED object:categories];
}
@end
