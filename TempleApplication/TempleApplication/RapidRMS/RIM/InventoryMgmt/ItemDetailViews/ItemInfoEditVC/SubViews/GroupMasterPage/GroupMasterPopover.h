//
//  I-RMS
//
//  Created by Siya Infotech on 12/09/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GroupMasterChangeDelegate <NSObject>
    -(void)didChangeGroupMaster:(NSString *)selectedGroupName GroupId:(NSString *)selectedGroupId;
    -(void)checkMixMatchGroupDiscount:(NSString *)groupDiscId;
@end
@interface GroupMasterPopover : UIViewController 
{
    
}
@property (nonatomic ,weak) id<GroupMasterChangeDelegate> GroupMasterChangeDelegate;

@property (nonatomic, strong) NSString *strGroupName;
@property (nonatomic, strong) NSString *strGroupID;

@end
