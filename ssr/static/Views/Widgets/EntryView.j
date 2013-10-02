@import "../../Models/Entry.j"
@import "CPUrlLabel.j"

@implementation EntryView : CPView
{
	CPUrlLabel siteUrl;
	CPTextField title;
	CPTextField published;
	CPWebView content;
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self)
    {
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

        content = [[CPWebView alloc] initWithFrame:CGRectMake(30.0, 80.0, CGRectGetWidth([self bounds]) - 60, 1000)]
        //[content setFont:fontDosis];
        //[content setLineBreakMode:CPLineBreakByWordWrapping];
        //[content setTextColor:[CPColor colorWithHexString:"999"]];
        [self addSubview:content];
    }
    return self;
}


- (void)setEntry:(Entry)entry
{
	[siteUrl setUrl:entry.link];
	[siteUrl setStringValue:entry.site];
	[siteUrl sizeToFit];

	[title setStringValue:entry.title];
	[title sizeToFit];

	[published setStringValue:entry.published];
	[title sizeToFit];

	[content loadHTMLString:entry.content];
}
@end

