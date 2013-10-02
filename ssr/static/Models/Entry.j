@import <Foundation/CPObject.j>

@implementation Entry : CPObject
{
	int id @accessors;
	CPString title @accessors;
	CPString link @accessors;
	CPString site @accessors;
	CPString content @accessors;
	CPString published @accessors;
	CPString author @accessors;
	CPString comments @accessors;
	BOOL unread @accessors;
	BOOL stared @accessors;
	CPString note @accessors;
}
- (id)initFromObject:(Object)obj
{
	var self  = [super init];
	if(self)
	{
		[self setId:obj.id];
		[self setTitle:obj.title];
		[self setLink:obj.link];
		[self setSite:obj.site];
		[self setContent:obj.content];
		[self setPublished:obj.published];
		[self setAuthor:obj.author];
		[self setComments:obj.comments];
		[self setUnread:obj.unread];
		[self setStared:obj.stared];
		[self setNote:obj.note];
	}
	return self;
}
@end
