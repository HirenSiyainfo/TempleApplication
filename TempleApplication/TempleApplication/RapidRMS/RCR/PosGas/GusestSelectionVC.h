//
//  GusestSelectionVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 4/17/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GusestSelectionVC : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (assign) NSInteger guestCount;

@property (NS_NONATOMIC_IOSONLY, readonly) NSInteger selectedGuestId;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSIndexPath *selectedIndexPath;
- (NSString*)labelTextForGuestAtPoint:(CGPoint)point;
- (CGPoint)centerForGuestAtPoint:(CGPoint)point;
-(void)reloadGuestView;

@end
