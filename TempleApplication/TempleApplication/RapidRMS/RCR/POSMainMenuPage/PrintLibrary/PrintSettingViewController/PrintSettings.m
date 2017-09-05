//
//  PrintSettings.m
//  POSFrontEnd
//
//  Created by Minesh Purohit on 10/02/12.
//  Copyright 2012 Home. All rights reserved.
//

#import "PrintSettings.h"
#import "MyPrintPageRenderer.h"
#import "PrinterFunctions.h"


@interface PrintSettings ()
@property (nonatomic, strong) RcrController *crmController;

@end

@implementation PrintSettings


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.crmController = [RcrController sharedCrmController];
	
	txtIPAddress.text = [self.crmController.savePrintSetting valueForKey:@"IpAddress"];
	txtPort.text = [self.crmController.savePrintSetting valueForKey:@"Port"];
	
}

- (IBAction) savePrintSetting:(id)sender {
	(self.crmController.savePrintSetting)[@"IpAddress"] = txtIPAddress.text;
	(self.crmController.savePrintSetting)[@"Port"] = txtPort.text;
	
	[self performSelector:@selector(doPrint)];
}


- (void) doPrint {
	NSArray *docPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *docFile=[docPaths.firstObject stringByAppendingPathComponent:@"printReceipt.html"];
	BOOL isExit;
	if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@",docFile] isDirectory:&isExit]) {
		NSError * isError;
		NSString * string = [NSString stringWithContentsOfFile:docFile encoding:NSUTF8StringEncoding error:&isError];
		
		NSString *portName = [self.crmController.savePrintSetting valueForKey:@"IpAddress"];
		NSString *portSettings = [self.crmController.savePrintSetting valueForKey:@"Port"];
		
		int heightExpansion = 400;
		int widthExpansion = 640;
		
		int leftMargin = string.intValue;
		
		Alignment alignment = pickerpopup_alignment.selectedIndex;
		NSData *textNSData = [string dataUsingEncoding:NSWindowsCP1252StringEncoding];
		unsigned char *textData = (unsigned char *)malloc(textNSData.length);
		[textNSData getBytes:textData];
		
		[PrinterFunctions PrintTextWithPortname:portName portSettings:portSettings slashedZero:YES underline:YES invertColor:YES emphasized:YES upperline:YES upsideDown:YES heightExpansion:heightExpansion widthExpansion:widthExpansion leftMargin:leftMargin alignment:alignment textData:textData textDataSize:textNSData.length];
		
		free(textData);
        
		
	}
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
