@import "Feed.j"

@implementation Category : CPObject
{
	int id @accessors;
	CPString name @accessors;
	int order @accessors;
	int parent @accessors;
	CPMutableArray feeds @accessors;
}

- (id)initFromObject:(Object)obj
{
	var self  = [super init];
	if(self)
	{
		[self setId:obj.id];
		[self setName:obj.name];
		[self setOrder:obj.order_id];
		[self setParent:obj.parent_id];

		feeds = [CPMutableArray array];
		for(var i = 0; i < obj.feeds.length; i++)
		{
			var uf = [[Feed alloc] initFromObject:obj.feeds[i]];
			[feeds addObject:uf];
		}
	}
	return self;
}
@end
