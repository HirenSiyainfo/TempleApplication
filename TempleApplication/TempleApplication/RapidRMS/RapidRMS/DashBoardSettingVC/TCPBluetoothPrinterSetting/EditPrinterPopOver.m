//
//  EditPrinterPopOver.m
//  RapidRMS
//
//  Created by Siya_Testing on 15/06/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import "EditPrinterPopOver.h"
#import "TCPBluetoothViewController.h"
#import "Printers.h"
@interface EditPrinterPopOver ()

@end

@implementation EditPrinterPopOver

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//- (void) viewWillLayoutSubviews{
//    [super viewWillLayoutSubviews];
//    if (!didLayout) {
//        [self layout];
//        didLayout = YES;
//    }
//}
//- (void) layout{
//    self.view.superview.backgroundColor = [UIColor clearColor];
//    CGRect screen = self.view.superview.bounds;
//    CGRect frame = CGRectMake(0, 0, <width>, <height>);
//    float x = (screen.size.width - frame.size.width)*.5f;
//    float y = (screen.size.height - frame.size.height)*.5f;
//    frame = CGRectMake(x, y, frame.size.width, frame.size.height);
//    
//    self.view.frame = frame;
//}
- (IBAction)btnDoneClicked:(id)sender {
    [self.editPrinterPopOverDelegate btnDonePress:self.txtTCPPortName.text TCPName:self.txtTCPName.text];
}

- (IBAction)btnCancelClicked:(id)sender {
    [self.editPrinterPopOverDelegate didCancel];
}
@end
