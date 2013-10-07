@import "CPFaviconView.j"

var CategoryDataViewImage = 1,
	CategoryDataViewText = 2,
	CategoryDataViewBadge = 3;
@implementation CategoryDataView : CPView
{
	CPFaviconView _image;
	CPTextField _text;
	CPTextField _badge;
	id _objectValue;
	CPString _stringValue;
}

- (id)initWithFrame:(CGRect)aFrame
{
	self = [super initWithFrame:aFrame];
    if (self)
    {
    	_image = [[CPFaviconView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    	[self addSubview:_image];

    	_text = [[CPTextField alloc] initWithFrame:CGRectMake(20.0, 0.0, 140.0, 25.0)];
    	[_text setVerticalAlignment:CPCenterVerticalTextAlignment];
    	[_text setLineBreakMode:CPLineBreakByTruncatingTail];
    	[self addSubview:_text];

    	_badge = [[CPTextField alloc] initWithFrame:CGRectMake(160.0, 0.0, 20.0, 25.0)];
    	[_badge setVerticalAlignment:CPCenterVerticalTextAlignment];
		[self addSubview:_badge];

	}
	return self;
}

- (void)setStringValue:(CPString)text
{
	_stringValue = text;
	[_text setStringValue:text];
}

- (void)setUnread:(int)unread
{
	[_badge setStringValue:unread];
}

- (void)setObjectValue:(id)object
{
	CPLog("CategoryDataView.setObjectValue:%@", object);
	_objectValue = object;
	if([object className] == 'Feed')
	{
		[_image setObjectValue:object];
	}
	[self setUnread:"0"];
}
@end
