@import <Foundation/CPObject.j>

@implementation User : CPObject
{
    int id @accessors;
    CPString username @accessors;
    CPString email @accessors;
    CPString fullname @accessors;
    CPDate lastLogin @accessors;
    CPString locale @accessors;
    CPString timezone @accessors;

}
- (id)initFromObject:(Object)obj
{
    if (self  = [super init])
    {
        [self setId:obj.id];
        [self setUsername:obj.username];
        [self setEmail:obj.email];
        [self setFullname:obj.fullname];
        [self setLastLogin:[[CPDate alloc] initWithTimeIntervalSince1970:obj.lastLogin]];
        [self setLocale:obj.locale];
        [self setTimezone:obj.timezone];
    }
    return self;
}
@end
