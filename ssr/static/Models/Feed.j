@implementation Feed : CPObject
{
	int id @accessors;
	CPString name @accessors;
	CPString site @accessors;
	int order @accessors;
	int unread @accessors;
}

- (id)initFromObject:(Object)obj
{
	var self  = [super init];
	if(self)
	{
		[self setId:obj.id];
		[self setName:obj.name];
		[self setSite:obj.site];
		[self setOrder:obj.order_id];
		[self setUnread:obj.unread];
	}
	return self
}
@end
