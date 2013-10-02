@import <Foundation/CPObject.j>

@implementation Headline : CPObject
{
	int id @accessors;
	CPString title @accessors;
	CPString site @accessors;
	CPString intro @accessors;
	BOOL unread @accessors;
	BOOL stared @accessors;
}
- (id)initFromObject:(Object)obj
{
	var self  = [super init];
	if(self)
	{
		[self setId:obj.id];
		[self setTitle:obj.title];
		[self setSite:obj.site];
		[self setIntro:obj.intro];
		[self setUnread:obj.unread];
		[self setStared:obj.stared];
	}
	return self;
}
@end
