//
//  MEHistroyFilterVC.h
//  RapidRMS
//
//  Created by Siya10 on 04/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MEFilterDelegate <NSObject>
-(void)didSubmitewithDate:(NSDate *)fromdate toDate:(NSDate *)todate;
@end

@interface MEHistroyFilterVC : UIViewController
@property (nonatomic, weak) id<MEFilterDelegate> meFilterDelegate;
@property(nonatomic, strong) NSDate *fromdate;
@property(nonatomic, strong) NSDate *todate;

@end
