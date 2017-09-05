
#include <Foundation/Foundation.h>
// for network rechability checking 
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

@interface UtilityManager : NSObject {
	
	UIView				* activityView;
	
	BOOL				isRunning;	
	BOOL				locationServicesEnabled;
	
}

@property BOOL isRunning;
@property (nonatomic, retain) UIView *activityView;


- (void)hideActivityViewer:(UIView *)window;

- (void)showActivityViewer:(UIView *)window;

@property (NS_NONATOMIC_IOSONLY, getter=isDataSourceAvailable, readonly) BOOL dataSourceAvailable;

@end

