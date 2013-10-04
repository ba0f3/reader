@import "../../Models/Entry.j"
@import "CPUrlLabel.j"
@import "CPHtmlView.j"

@implementation EntryView : CPView
{
	CPUrlLabel siteUrl;
	CPTextField title;
	CPTextField published;
	CPHtmlView content;
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self)
    {
    	var defaultCenter = [CPNotificationCenter defaultCenter];
    	[defaultCenter addObserver:self selector:@selector(viewFrameChanged:) name:CPViewFrameDidChangeNotification object:content];

		[self setAutoresizesSubviews:NO];

    	var fontDosisBoldBig = [CPFont boldFontWithName:'Dosis' size:22];
    	var fontDosisBold = [CPFont boldFontWithName:'Dosis' size:14];
        var fontDosis = [CPFont fontWithName:'Dosis' size:14];
        var fontDosisSmall = [CPFont fontWithName:'Dosis' size:12];

    	siteUrl = [[CPUrlLabel alloc] initWithFrame:CGRectMake(30.0, 15.0, CGRectGetWidth([self bounds]) - 60, 24)];
        [siteUrl setFont:fontDosis];
        [siteUrl setTextColor:[CPColor colorWithHexString:"ccc"]];
        [self addSubview:siteUrl];

        title = [[CPTextField alloc] initWithFrame:CGRectMake(30.0, 30.0, CGRectGetWidth([self bounds]) - 60, 30)]
        [title setFont:fontDosisBoldBig];
        [title setTextColor:[CPColor colorWithHexString:"fff"]];
        [self addSubview:title];

        published = [[CPTextField alloc] initWithFrame:CGRectMake(30.0, 60.0, CGRectGetWidth([self bounds]) - 60, 14)]
        [published setFont:fontDosisSmall];
        [published setTextColor:[CPColor colorWithHexString:"ccc"]];
        [self addSubview:published];

        content = [[CPHtmlView alloc] initWithFrame:CGRectMake(30.0, 80.0, CGRectGetWidth([self bounds]) - 60, CGRectGetHeight([self bounds]) - 80)]
        [content setBackgroundColor:[CPColor colorWithHexString:@"222"]]
        [content setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
        [content setFont:fontDosis];
        [content setTextColor:[CPColor colorWithHexString:"ccc"]];
        [self addSubview:content];
    }
    return self;
}


- (void)viewFrameChanged:(CPNotification)aNotification
{
	CPLog("EntryView.viewFrameChanged:%@", aNotification);
	[self resizeToFit];
}

- (void)resizeToFit
{
	var subviews = [self subviews];
	var frame = CGRectMakeZero();;
	for(var i = 0; i < subviews.length; i++)
	{
		var subview = subviews[i];
		frame = CGRectUnion(frame, [subview frame]);
	}
	[self setFrameSize:CGSizeMake(CGRectGetWidth(frame), CGRectGetHeight(frame) + 20)];
}

- (void)setEntry:(Entry)entry
{
	[siteUrl setUrl:entry.link];
	[siteUrl setStringValue:entry.site];
	[siteUrl sizeToFit];

	[title setStringValue:entry.title];
	[title sizeToFit];

	[published setStringValue:entry.published];
	[published sizeToFit];

	[content setHTMLString:entry.content];
}
@end

