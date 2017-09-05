//
//  CustomerDisplayViewController.m
//  POSRetail
//
//  Created by Siya Infotech on 18/12/13.
//  Copyright (c) 2013 Nirav Patel. All rights reserved.
//

#import "CustomerDisplayViewController.h"
#import "RmsDbController.h"
#import "CustomerDisplayBrowserVC.h"
#import "CustomerDisplayClient.h"
#import "RcrController.h"

@interface CustomerDisplayViewController ()<CustomerDisplayBrowserVCDelegate, DisplayDataReceiver>

@property (nonatomic, weak) IBOutlet UIButton *connectDisconnectButton;
@property (nonatomic, weak) IBOutlet UIButton *btn_Browse;

@property (nonatomic, weak) IBOutlet UILabel *lblDisplayStatus;

@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) MCBrowserViewController *browserVC;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiser;
@property (nonatomic, strong) MCSession *mySession;
@property (nonatomic, strong) MCPeerID *myPeerID;

@property (nonatomic, weak) UIButton *browserButton;
@property (nonatomic, weak) UITextField *chatBox;
@property (nonatomic, weak) UITextView *textBox;


@end

@implementation CustomerDisplayViewController

@synthesize browserVC,advertiser;
@synthesize mySession,myPeerID;
@synthesize browserButton,chatBox,textBox,lblDisplayStatus;


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
   // [self setUpUI];
    self.crmController = [RcrController sharedCrmController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];


    self.lblDisplayStatus.text=@"Disconneceted";

    //
  
    
    [self setUpMultipeer];
    
    self.lblDisplayStatus.text = self.crmController.displayName;
    if (self.crmController.displayConnected) {
        self.lblDisplayStatus.backgroundColor = [UIColor greenColor];
        self.connectDisconnectButton.hidden = NO;
    } else {
        self.lblDisplayStatus.backgroundColor = [UIColor redColor];
        self.connectDisconnectButton.hidden = YES;
    }

}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title=@"Customer Display";
}

-(void) viewWillDisappear:(BOOL)animated
{
   
    [super viewWillDisappear:animated];
}

- (void) setUpMultipeer
{
    //  Setup peer ID
    self.myPeerID = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
    
    //  Setup session
    self.mySession = [[MCSession alloc] initWithPeer:self.myPeerID];
    self.mySession.delegate = self;
    
//    self.advertiseSession = [[MCSession alloc] initWithPeer:self.myPeerID];
//    self.advertiseSession.delegate = self;
    
    //  Setup BrowserViewController
    self.browserVC = [[MCBrowserViewController alloc] initWithServiceType:@"chat" session:self.mySession];
    self.browserVC.delegate = self;

    //  Setup Advertiser
//    self.advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:@"chat" discoveryInfo:nil session:self.advertiseSession];
//    [self.advertiser start];
}
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [self dismissBrowserVC];
}

// Notifies delegate that the user taps the cancel button.
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [self dismissBrowserVC];
}

- (IBAction)btn_ShowPeerConnection:(id)sender
{
    [self presentViewController:self.browserVC animated:YES completion:nil];
}
- (void) showBrowserVC
{
  //  [self presentViewController:self.browserVC animated:YES completion:nil];
    CustomerDisplayBrowserVC *custDispvc=[[CustomerDisplayBrowserVC alloc]initWithNibName:@"CustomerDisplayBrowserVC" bundle:nil];
    custDispvc.browserDelegate = self;
    [self presentViewController:custDispvc animated:YES completion:nil];
    
}

- (void) dismissBrowserVC
{
    self.crmController.singleTap1.enabled = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self Showalert:state];
        });
}
-(void)Showalert:(int)state
{
    if (state==0)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Customer Display device is disconnected" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        
        self.lblDisplayStatus.text=@"Disconneceted";
    }
    else
    {
        self.lblDisplayStatus.text=@"Conneceted";
    }
}
- (void) sendData :(NSMutableArray *)responseArray
{
    //  Retrieve text from chat box and clear chat box
   // NSString * message = [self.crmController.reciptDataAry componentsJoinedByString:@","];
    // message = [message stringByReplacingOccurrencesOfString: @"\n" withString:@""];
    //  message = [message stringByReplacingOccurrencesOfString: @"\n" withString:@""];
    //  Convert text to NSData
    //  NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:responseArray];
    //  Send data to connected peers
    NSError *error;
    [self.mySession sendData:data toPeers:self.mySession.connectedPeers withMode:MCSessionSendDataUnreliable error:&error];
    //  Append your own message to text box
}


// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    //  Decode data back to NSString
    //NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //  append message to text box:
    dispatch_async(dispatch_get_main_queue(), ^{
    });
}

// Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    
}

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    
}

// Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
}

- (IBAction)btn_Browse:(id)sender {
    [self showBrowserVC];
}
- (void)serviceSelected:(NSNetService *)selectedService {
    [self.crmController.customerDisplayClient openStreamsToNetService:selectedService];
} 
//- (void)didConnectToPos:(NSNotification*)notification {
//    NSDictionary *dictionary = notification.userInfo;
//    NSString *posName = [dictionary objectForKey:@"DisplayName"];
//    self.lblDisplayStatus.text = posName;
//    self.lblDisplayStatus.backgroundColor = [UIColor greenColor];
//    
//    self.connectDisconnectButton.hidden = NO;
//    
//    // Send junk data
//}
//- (void)didDisconnectToPos:(NSNotification*)notification {
//    NSDictionary *dictionary = notification.userInfo;
//    NSString *posName = [dictionary objectForKey:@"DisplayName"];
//    self.lblDisplayStatus.text = posName;
//    self.lblDisplayStatus.backgroundColor = [UIColor redColor];
//    self.connectDisconnectButton.hidden = YES;
//}
- (void)didConnectToPos:(NSString*)posName{
    
}
- (void)didDisconnectToPos:(NSString*)posName{
    
}

- (IBAction)disconnectDisplay:(id)sender {
//    if (self.crmController.isDisplayConnected) {
        [self.crmController.customerDisplayClient disconnectFromDisplay];
//    } else {
//        [self.crmController.customerDisplayClient reconnectToPreviousPos];
//    }
}
@end
