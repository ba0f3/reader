@implementation LocalSetting : CPObject
{
}

- (id)init
{
    if (self = [super init])
    {

    }
    return self;
}

+ (id)get:(CPString)key
{
    return window.localStorage.hasOwnProperty(key)?JSON.parse(window.localStorage[key]):nil;
}

+ (id)setObject:(CPObject)obj forKey:(CPString)key
{
    if (typeof(obj) != "string")
        obj = JSON.stringify(obj)
    return window.localStorage[key] = obj;
}
@end
