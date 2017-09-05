//
//  ExportPopupVC.h
//  RapidRMS
//
//  Created by Siya9 on 26/04/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupSuperVC.h"

typedef NS_ENUM(NSInteger, ExportType)
{
    ExportTypeEmail = 1,
    ExportTypePrieview = 2
};
@protocol ExportPopupVCDelegate <NSObject>
-(void)didSelectExportType:(ExportType)exportType withTag:(NSInteger)tag;
@end
@interface ExportPopupVC : PopupSuperVC

@property (nonatomic, weak) id<ExportPopupVCDelegate> delegate;
@property (nonatomic) NSInteger tag;


@end
