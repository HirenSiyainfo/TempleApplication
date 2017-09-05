//
//  EditPrinterPopOver.h
//  RapidRMS
//
//  Created by Siya_Testing on 15/06/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol EditPrinterPopOverDelegate <NSObject>
-(void)btnDonePress:(NSString *)TCPPortname TCPName:(NSString *)TCPName;
-(void)didCancel;

@end

@interface EditPrinterPopOver : UIViewController
@property (nonatomic, strong) id<EditPrinterPopOverDelegate> editPrinterPopOverDelegate;
@property (weak, nonatomic) IBOutlet UITextField *txtTCPPortName;
@property (weak, nonatomic) IBOutlet UITextField *txtTCPName;

- (IBAction)btnDoneClicked:(id)sender;
- (IBAction)btnCancelClicked:(id)sender;

@end
