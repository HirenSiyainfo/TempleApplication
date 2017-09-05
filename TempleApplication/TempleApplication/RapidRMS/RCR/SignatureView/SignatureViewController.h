//
//  SignatureViewController.h
//
//  Created by John Montiel on 5/11/12.
//

#import <UIKit/UIKit.h>
#import "SignatureView.h"

@class SignatureViewController;

@protocol SignatureViewControllerDelegate <NSObject>
- (void) signatureViewController:(SignatureViewController *)viewController didSign:(NSData *)signatur signature:(UIImage *)signatureImage withCustomerDisplayTipAmount:(CGFloat )tips;
- (void) manualReceipt;
@end


@interface SignatureViewController : UIViewController
{
   
}


@property (nonatomic, strong) NSMutableDictionary *signatureDataDict;

@property (nonatomic , weak) IBOutlet SignatureView *signview;
@property (nonatomic , weak) IBOutlet UITextField *signatureTextField;

@property (weak, nonatomic) id<SignatureViewControllerDelegate> delegate;

- (IBAction)signatureClearTapped:(id)sender;
- (IBAction)manualRecriptTapped:(id)sender;
- (IBAction)signatureSignTapped:(id)sender;
- (void)checkSign;

@end
