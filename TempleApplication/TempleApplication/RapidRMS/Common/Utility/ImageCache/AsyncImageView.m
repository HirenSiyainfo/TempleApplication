//
//  AsyncImageView.m
//  YellowJacket
//
//  Created by Wayne Cochran on 7/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AsyncImageView.h"
#import "ImageCacheObject.h"
#import "NewImageCache.h"


static NSOperationQueue *imageDownloadQueue = nil;


@interface AsyncImageView ()  {
    NSBlockOperation *downloadOperation;
    NSURLSession *session;
    NSURLSessionDownloadTask *downloadTask;
}

@property (nonatomic, weak) UIImageView *internalImageView;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, weak) UIActivityIndicatorView *spinny;

@end

@implementation AsyncImageView


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupAsynchView];
    }
    return self;
}

- (void)awakeFromNib {
    [self setupAsynchView];
}

- (void)addNewImageView {
    [self.internalImageView removeFromSuperview];
	UIImageView * internalImageView = [[UIImageView alloc] initWithFrame:self.bounds];
	internalImageView.contentMode = UIViewContentModeScaleAspectFill;
	[internalImageView setClipsToBounds:YES];
    
    if (self.imageCornerRadius > 0.0) {
        internalImageView.layer.cornerRadius = self.imageCornerRadius;
        self.imageCornerRadius = 0.0;
    }
    
	internalImageView.backgroundColor = [UIColor clearColor];
	internalImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self addSubview:internalImageView];
    self.internalImageView = internalImageView;
}

- (void)addSPinny {
    UIActivityIndicatorView *spinny;
	spinny = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    CGRect frame = spinny.bounds;
    frame.origin.x = (self.bounds.size.width-frame.size.width )/2;
    frame.origin.y = (self.bounds.size.height-frame.size.height )/2;
    spinny.frame = frame;

    spinny.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    spinny.hidesWhenStopped = YES;
    [self addSubview:spinny];
    self.spinny = spinny;
}

- (void)setupAsynchView {
    if (imageDownloadQueue == nil) {
        imageDownloadQueue = [[NSOperationQueue alloc] init];
        imageDownloadQueue.name = @"Queue.ImageDownload.Rms";
    }
    if (session == nil) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration:sessionConfig];
    }
    [self addNewImageView];
    [self addSPinny];
}

- (void) setImage:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
       
        if (self.imageCornerRadius > 0.0) {
            self.internalImageView.layer.cornerRadius = self.imageCornerRadius;
            self.imageCornerRadius = 0.0;
        }
        self.internalImageView.image = image;
        
        
        if (image == nil) {
            [self.spinny startAnimating];
        }
        else
        {
            [self.spinny stopAnimating];
        }
    });
}

-(void)loadImageFromURL:(NSURL*)url {
    [self.spinny startAnimating];
    self.data = nil;
    //    [self addNewImageView];
    
    [self setImage:nil];
    self.urlString = [url.absoluteString copy];
    
#if 0
    [self startDownload:url];
#else
    UIImage *image;
    NSString *imgUrl = url.absoluteString;
    
    if ([[NewImageCache sharedImageCache] DoesExist:imgUrl] == true)
    {
        image = [[NewImageCache sharedImageCache] GetImage:imgUrl];
        self.image = image;
    }
    else{
        [downloadTask cancel];
        downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error){
            NSData *data = [NSData dataWithContentsOfURL:location];
            if (data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [UIImage imageWithData:data];
                    if (image) {
//                        image = [[NewImageCache sharedImageCache] resizeImage:image scaledToSize:CGSizeMake(100, 100)];
                        self.image = image;
                        [[NewImageCache sharedImageCache] AddImage:imgUrl withImage:image];
                    }
                });
            }
        }];
        [downloadTask resume];
    }
    
#endif
}

-(void)cancelDownloadTask{
    [downloadTask cancel];
}

-(void)startDownload:(NSURL *)url {
    [downloadOperation cancel];
    
    __weak  AsyncImageView *asyncImageView = self;
    
    downloadOperation = [NSBlockOperation blockOperationWithBlock:^{
        asyncImageView.data = [[NSData dataWithContentsOfURL:url] mutableCopy];
    }];
    __weak  NSBlockOperation *blockOperation = downloadOperation;
    
    downloadOperation.completionBlock = ^{
        if (blockOperation == nil) {
            return ;
        }
        if (!blockOperation.isCancelled) {
            UIImage *image = [UIImage imageWithData:asyncImageView.data];
            asyncImageView.image = image;
        }
    };
    
    [imageDownloadQueue addOperation:downloadOperation];
}

- (UIImage*) image {
    return self.internalImageView.image;
}

@end
