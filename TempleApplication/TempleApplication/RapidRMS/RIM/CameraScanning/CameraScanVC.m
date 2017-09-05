//
//  CameraScanVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 28/04/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "CameraScanVC.h"
#import "RmsDbController.h"
#import "RimsController.h"
#import "ItemTicketValidation.h"

@interface CameraScanVC ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, weak) IBOutlet UIView *cameraScanningView;

@property (nonatomic, strong) RimsController *rimsController;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@property (nonatomic, strong) NSString *strBarcode;
@property (nonatomic) BOOL isReading;

@end

@implementation CameraScanVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rimsController = [RimsController sharedrimController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden = YES;
    [self startReading];
}

#pragma mark - Private method implementation

- (BOOL)startReading {
    NSError *error;
    
    // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
    // as the media type parameter.
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Get an instance of the AVCaptureDeviceInput class using the previous device object.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        // If any error occurs, simply log the description of it and don't continue any more.
        NSLog(@"%@", error.localizedDescription);
        return NO;
    }
    
    // Initialize the captureSession object.
    _captureSession = [[AVCaptureSession alloc] init];
    // Set the input device on the capture session.
    [_captureSession addInput:input];
    
    
    // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    // Create a new serial dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    captureMetadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeQRCode];
    
    // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    _videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _videoPreviewLayer.frame = _cameraScanningView.layer.bounds;
    [_cameraScanningView.layer addSublayer:_videoPreviewLayer];

    // Start video capture.
    [_captureSession startRunning];
    
    [self changeCameraOrientationAsDeviceOrientation];
    
    return YES;
}

- (void)changeCameraOrientationAsDeviceOrientation
{
    AVCaptureVideoOrientation newOrientation = AVCaptureVideoOrientationPortrait;
    
    UIInterfaceOrientation deviceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if(IsPad())
    {
        if(deviceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            newOrientation = AVCaptureVideoOrientationLandscapeRight;
        }
        else if(deviceOrientation == UIInterfaceOrientationLandscapeLeft)
        {
            newOrientation = AVCaptureVideoOrientationLandscapeLeft;
        }
    }
    else
    {
        if(deviceOrientation == UIInterfaceOrientationPortrait)
        {
            newOrientation = AVCaptureVideoOrientationPortrait;
        }
        else if(deviceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            newOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
        }
    }
    AVCaptureConnection *previewLayerConnection = _videoPreviewLayer.connection;
    
    if (previewLayerConnection.supportsVideoOrientation)
    {
        previewLayerConnection.videoOrientation = newOrientation;
    }
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self changeCameraOrientationAsDeviceOrientation];
}

-(void)stopReading{
    // Stop video capture and make the capture session object nil.
    [_captureSession stopRunning];
    _captureSession = nil;
    
    // Remove the video preview layer from the viewPreview view's layer.
    [_videoPreviewLayer removeFromSuperlayer];
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    // Check if the metadataObjects array is not nil and it contains at least one object.
    if (metadataObjects != nil && metadataObjects.count > 0) {
        // Get the metadata object.
        AVMetadataMachineReadableCodeObject *metadataObj = metadataObjects.firstObject;
        //if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
        // If the found metadata is equal to the QR code metadata then update the status label's text,
        // stop reading and change the bar button item's title and the flag's value.
        // Everything is done on the main thread.
        
        //            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
        //            [_bbitemStart performSelectorOnMainThread:@selector(setTitle:) withObject:@"Start!" waitUntilDone:NO];
        
        _isReading = NO;
        
        // If the audio player is not nil, then play the sound effect.
        //            if (_audioPlayer) {
        //                [_audioPlayer play];
        //            }
        
        if (metadataObj.stringValue != nil) {
            [self stopReading];
            NSArray *arrMetaData = [metadataObj.stringValue componentsSeparatedByString:@";"];
            _strBarcode = arrMetaData.firstObject;
            
            if(_strBarcode != nil){
                if([metadataObj.type isEqualToString:AVMetadataObjectTypeEAN13Code]){
                    if ([_strBarcode hasPrefix:@"0"] && _strBarcode.length > 1)
                        _strBarcode = [_strBarcode substringFromIndex:1];
                }
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.delegate barcodeScanned:_strBarcode];
                [self dismissViewControllerAnimated:YES completion:nil];
            });
            
        }
        else
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
            
        }
        // }
    }
}

- (IBAction)btnBackClicked:(id)sender
{
    if (!self.presentingViewController) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

@end
