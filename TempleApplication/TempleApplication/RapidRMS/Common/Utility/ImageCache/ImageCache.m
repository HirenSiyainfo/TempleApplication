
#import "ImageCache.h"
#import "ImageCacheObject.h"

@interface ImageCache ()
@property (atomic, strong) NSMutableDictionary *myDictionary;
@property (nonatomic, strong) NSLock *imageCacheLock;
@end


@implementation ImageCache

@synthesize totalSize;

-(instancetype)initWithMaxSize:(NSUInteger) max  {
    if (self = [super init]) {
        totalSize = 0;
        maxSize = max;
        self.imageCacheLock = [[NSLock alloc] init];
        _myDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)dealloc
{
    _myDictionary = nil;
}

-(void)_insertImage:(UIImage*)image withSize:(NSUInteger)sz forKey:(NSString*)key{
    ImageCacheObject *object = [[ImageCacheObject alloc] initWithSize:sz Image:image];
    while (totalSize + sz > maxSize) {
        NSDate *oldestTime;
        NSString *oldestKey;
        
        for (NSString *key in [_myDictionary.allKeys copy])
        {
            ImageCacheObject *obj = _myDictionary[key];
            if (oldestTime == nil || [obj.timeStamp compare:oldestTime] == NSOrderedAscending) {
                oldestTime = obj.timeStamp;
                oldestKey = key;
            }
        }
        if (oldestKey == nil)
            break; // shoudn't happen
        ImageCacheObject *obj = _myDictionary[oldestKey];
        
        totalSize -= obj.size;
        [_myDictionary removeObjectForKey:oldestKey];
        
    }
    _myDictionary[key] = object;
}

-(void)insertImage:(UIImage*)image withSize:(NSUInteger)sz forKey:(NSString*)key
{
    [self.imageCacheLock lock];
    [self _insertImage:image withSize:sz forKey:key];
    [self.imageCacheLock unlock];
}

-(UIImage*)imageForKey:(NSString*)key {
    
    if(key == nil)
    {
        return nil;
    }
    
    ImageCacheObject *object = _myDictionary[key];
    if (object == nil)
        return nil;
    [object resetTimeStamp];
    return object.image;
}

@end
