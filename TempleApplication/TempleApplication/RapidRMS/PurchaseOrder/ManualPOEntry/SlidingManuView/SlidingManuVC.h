//
//  SlidingManuVC.h
//  RapidRMS
//
//  Created by Siya on 21/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ManuSelecteItemDelegate
-(void)didSelectManu:(NSString *) strManuName;
@end

@interface SlidingManuVC : UIViewController

@property (nonatomic, weak) id<ManuSelecteItemDelegate> manuSelecteItemDelegate;

@end
