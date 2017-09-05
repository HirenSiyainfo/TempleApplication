//
//  ExportPopupVC.m
//  RapidRMS
//
//  Created by Siya9 on 26/04/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "ExportPopupVC.h"

@interface ExportPopupVC ()

@end

@implementation ExportPopupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)exportTypeClick:(UIButton *)sender{
    [self popoverPresentationControllerShouldDismissPopover];
    
    if ([self.delegate respondsToSelector:@selector(didSelectExportType:withTag:)]) {
        [self.delegate didSelectExportType:(ExportType)sender.tag withTag:self.tag];
    }
}

@end
