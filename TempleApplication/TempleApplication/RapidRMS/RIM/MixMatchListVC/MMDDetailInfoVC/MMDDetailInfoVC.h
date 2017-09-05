//
//  MMDDetailInfoVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 22/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Discount_M.h"

@interface MMDDetailInfoVC : UIViewController

@property (nonatomic, strong) NSManagedObjectContext * moc;
@property (nonatomic, strong) Discount_M * objMixMatch;

@end
