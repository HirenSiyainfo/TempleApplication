
#import "UtilityManager.h"
#import "OLImageView.h"
#import "OLImage.h"

@implementation UtilityManager

@synthesize activityView;
@synthesize isRunning;


//hide Activity Indicator.
-(void)hideActivityViewer:(UIView *)window
{
	if( isRunning ){
//		[[[activityView subviews] firstObject] stopAnimating];
		[activityView removeFromSuperview];
		activityView = nil;
		isRunning = NO;
	}
}


//Show Activity Indicator.
-(void)showActivityViewer:(UIView *)window
{
	if( !isRunning )
	{
		[activityView release];
		activityView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, window.bounds.size.width, window.bounds.size.height)];
		activityView.backgroundColor = [UIColor blackColor];
        activityView.alpha = 0.5;
		activityView.center = CGPointMake(window.frame.size.width/2, window.frame.size.height/2);
        activityView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//        activityView.frame = window.bounds;
        
/*		UIActivityIndicatorView *activityWheel = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(window.bounds.size.width / 2 - 12, window.bounds.size.height / 2 - 12, 24, 24)];
		activityWheel.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
		activityWheel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
										  UIViewAutoresizingFlexibleRightMargin |
										  UIViewAutoresizingFlexibleTopMargin |
										  UIViewAutoresizingFlexibleBottomMargin);
		activityWheel.backgroundColor=[UIColor clearColor];
		activityWheel.center=CGPointMake(window.frame.size.width/2, window.frame.size.height/2);
		[activityView insertSubview:activityWheel atIndex:1];
		[activityWheel release];*/
				
        
        OLImageView *imageView = [[OLImageView alloc] initWithImage:[OLImage imageNamed:@"RapidLoadingLogo.gif"]];
		imageView.backgroundColor = [UIColor clearColor];
		imageView.layer.shadowOffset = CGSizeMake(0, 2);
		imageView.frame=CGRectMake(window.bounds.size.width / 2 - 64, window.bounds.size.height / 2 - 64, 55, 55);
		imageView.layer.cornerRadius = 5;
		imageView.center=CGPointMake(window.frame.size.width/2, window.frame.size.height/2);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
		[activityView insertSubview:imageView atIndex:0];
        
        /*imageView.layer.shadowOpacity = 70;
       //[[[activityView subviews] objectAtIndex:1] startAnimating];
        //imageView.center=activityWheel.center;*/

		
		UILabel *lodingLbl = [[UILabel alloc] initWithFrame:CGRectMake(activityView.frame.size.width/2-64, activityView.frame.size.height/2+35 , 128, 40)];
		lodingLbl.text = @"Loading...";
		lodingLbl.backgroundColor = [UIColor clearColor];
		lodingLbl.textAlignment = NSTextAlignmentCenter;
		lodingLbl.font = [UIFont fontWithName:@"Helvetica Neue" size:20];
		lodingLbl.textColor = [UIColor darkGrayColor];

        lodingLbl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;

        [activityView insertSubview:lodingLbl atIndex:1];
		activityView.layer.cornerRadius = 5;
		
		[window addSubview: activityView];
		
		[imageView release];
		[lodingLbl release];
		[activityView release];
		
		isRunning=YES;
	}
}


#pragma mark -
#pragma mark check internet capability.

// check to internet connetion avability
- (BOOL)isDataSourceAvailable {
	
	static BOOL _isDataSourceAvailable = NO;
	
	// Create zero addy
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	
	// Recover reachability flags
	SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
	SCNetworkReachabilityFlags flags;
	
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
	CFRelease(defaultRouteReachability);
	
	if (!didRetrieveFlags)
	{
		printf("Error. Could not recover network reachability flags\n");
		return 0;
	}
	
	BOOL isReachable = flags & kSCNetworkFlagsReachable;
	BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	
	_isDataSourceAvailable = (isReachable && !needsConnection) ? YES : NO;
	
    return _isDataSourceAvailable;
	
}


- (void)dealloc{

	[activityView dealloc];
	
	[super dealloc];
}


@end
