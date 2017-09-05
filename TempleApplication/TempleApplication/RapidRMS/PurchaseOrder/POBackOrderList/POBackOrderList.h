//
//  POBackOrderList.h
//  RapidRMS
//
//  Created by Siya10 on 16/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol POBackOrderDelegate <NSObject>

-(void)didSelectBackorderItems:(NSMutableArray *)items;
@end

@interface POBackOrderList : UIViewController

@property(nonatomic, weak) id<POBackOrderDelegate> bodelegate;
@end
