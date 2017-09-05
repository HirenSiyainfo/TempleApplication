//
//  MMDMasterListVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 20/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, MasterTypes)
{
    MasterTypesDepartment,
    MasterTypesTAG,
    MasterTypesGroup,
};
@protocol DidSelectMasterDelegate <NSObject>
    -(void)didSelectMasterInfo:(NSPredicate *) filterMaster;
@end
@interface MMDMasterListVC : UIViewController

@property (nonatomic, weak) id<DidSelectMasterDelegate> Delegate;
@property (nonatomic) MasterTypes selectedMaster;

@end
