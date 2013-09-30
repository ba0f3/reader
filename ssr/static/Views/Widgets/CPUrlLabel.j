@import <AppKit/CPTextField.j>

@implementation CPUrlLabel : CPTextField
{
	CPString url;
}

- (void)setUrl:(CPString)aUrl
{
	if (aUrl === nil || aUrl === undefined)
	{
		CPLog.warn("nil or undefined sent to CPUrlLabel -setUrl");
		return;
	}
	url = aUrl;
}

- (id)initWithFrame:(CGRect)aFrame
 {
 	self = [super initWithFrame:aFrame]
 	if(self)
 	{
 		url = @"";
 		[self setStringValue:@""];
 		[self setUrl:@""];
 	}
 	return self;
 }

- (void)mouseDown:(CPEvent)anEvent
{
	if (url === nil || url === undefined)
	{
		CPLog.warn("no url defined CPUrlLabel -mouseDown");
		return;
	}
	window.open(url, '_blank');
}

@end
