//
//  CustomerDisplayClient.m
//  CustomerDisplayApp
//
//  Created by Siya Infotech on 02/04/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "CustomerDisplayClient.h"
#import "QNetworkAdditions.h"
#import "CustomerDisplayBrowser.h"
#import "TenderViewController.h"


#define kPOS_NAME @"PosName"
#define SIZE_OF_HEADER (sizeof(uint64_t))

@interface CustomerDisplayClient () <NSStreamDelegate, CustomerDisplayBrowserDelegate>
@property (nonatomic, weak) id <DisplayDataReceiver>displayReceiver;

@property (nonatomic, strong, readwrite) NSInputStream *        inputStream;
@property (nonatomic, strong, readwrite) NSOutputStream *       outputStream;
@property (nonatomic, strong, readwrite) NSMutableData *        inputBuffer;
@property (atomic, strong, readwrite) NSMutableData *        outputBuffer;

@property (nonatomic, strong) NSMutableData *dataFromPos;

@property (nonatomic, strong) NSString *nameOfPreviousPos;

@property (nonatomic, strong) NSRecursiveLock *outputBufferLock;

@property (nonatomic, strong) CustomerDisplayBrowser *customerDisplayBrowser;
// forward declarations

- (void)closeStreams;

@end

@implementation CustomerDisplayClient

- (instancetype)initWithDelegate:(id<DisplayDataReceiver>)displayReceiver {
    self = [super init];
    
    if (self) {
        self.displayReceiver = displayReceiver;
        [self reconnectToPreviousPos];
        self.isConnected = NO;
        self.outputBufferLock = [[NSRecursiveLock alloc] init];
    }
    
    return self;
}

#pragma mark -
#pragma mark Stream methods

- (void)openStreamsToNetService:(NSNetService *)netService {
    NSInputStream * istream;
    NSOutputStream * ostream;
    
    [self closeStreams];
    
    if ([netService qNetworkAdditions_getInputStream:&istream outputStream:&ostream]) {
        self.customerDisplayBrowser = nil;
        [self saveNameOfPos:netService.name];
        self.inputStream = istream;
        self.outputStream = ostream;
        self.inputStream.delegate = self;
        self.outputStream.delegate = self;
        [self.inputStream  scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.inputStream  open];
        [self.outputStream open];
        self.isConnected = YES;
    }
}

- (void)closeStreams {
    self.customerDisplayBrowser = nil;
    if (self.isConnected) {
        self.isConnected = NO;
        [self.inputStream  setDelegate:nil];
        [self.outputStream setDelegate:nil];
        [self.inputStream  close];
        [self.outputStream close];
        [self.inputStream  removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.inputStream  = nil;
        self.outputStream = nil;
        self.inputBuffer  = nil;
        self.outputBuffer = nil;
        [self.displayReceiver didDisconnectToPos:[self storedNameOfPos]];
    }
}

- (void)disconnectFromDisplay {
    self.customerDisplayBrowser = nil;
    if (self.isConnected) {
        self.isConnected = NO;
        [self.inputStream  setDelegate:nil];
        [self.outputStream setDelegate:nil];
        [self.inputStream  close];
        [self.outputStream close];
        [self.inputStream  removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.inputStream  = nil;
        self.outputStream = nil;
        self.inputBuffer  = nil;
        self.outputBuffer = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DisconnectedToDisplay" object:nil userInfo:@{@"DisplayName": [self storedNameOfPos]}];
    }
}

//- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent {
//    assert(aStream == self.inputStream || aStream == self.outputStream);
//#pragma unused(aStream)
//    
//    switch(streamEvent) {
//        case NSStreamEventOpenCompleted: {
//            [self.displayReceiver didConnectToPos:[self storedNameOfPos]];
//            
//        } break;
//        case NSStreamEventEndEncountered:
//        case NSStreamEventErrorOccurred: {
//            [self closeStreams];
//            [self.displayReceiver didDisconnectToPos:[self storedNameOfPos]];
//        } break;
//        case NSStreamEventHasSpaceAvailable: {
//                // TODO
//        } break;
//        case NSStreamEventHasBytesAvailable:
//        default: {
//            // do nothing
//        } break;
//    }
//}

- (void)saveNameOfPos:(NSString*)nameOfPos {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:nameOfPos forKey:kPOS_NAME];
    [userDefaults synchronize];
}

- (NSString*)storedNameOfPos {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kPOS_NAME];
}

- (void)reconnectToPreviousPos {
    self.nameOfPreviousPos = [self storedNameOfPos];
    if (self.nameOfPreviousPos) {
        [self.customerDisplayBrowser stopBrowsing];
        self.customerDisplayBrowser = nil;
        self.customerDisplayBrowser = [[CustomerDisplayBrowser alloc] initWithDelegate:self];
        
    }
}

- (void)didFindPos:(NSNetService*)posService {
    if ([posService.name isEqualToString:self.nameOfPreviousPos]) {
        // We found the pos.
        // Connect now
        [self.customerDisplayBrowser stopBrowsing];
        self.customerDisplayBrowser = nil;
        [self openStreamsToNetService:posService];
    }
}


- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent {
    //    assert(aStream == self.inputStream || aStream == self.outputStream);
    switch(streamEvent) {
        case NSStreamEventOpenCompleted: {
            // We don't create the input and output buffers until we get the open-completed events.
            // This is important for the output buffer because -outputText: is a no-op until the
            // buffer is in place, which avoids us trying to write to a stream that's still in the
            // process of opening.
            if (aStream == self.inputStream) {
                self.inputBuffer = [[NSMutableData alloc] init];
            } else {
                self.outputBuffer = [[NSMutableData alloc] init];
            }
            [self.displayReceiver didConnectToPos:[self storedNameOfPos]];
        } break;
        case NSStreamEventHasSpaceAvailable: {
            if (self.outputBuffer.length != 0) {
                [self startOutput];
            }
        } break;
        case NSStreamEventHasBytesAvailable: {
            
            NSLog(@"    NSStreamEventHasBytesAvailable");
            uint8_t buffer[1024];
            NSInteger actuallyRead = [self.inputStream read:(uint8_t *)buffer maxLength:sizeof(buffer)];
            NSLog(@"Actually Read = %ld", (long)actuallyRead);
            if (actuallyRead > 0) {
                // Write it to display
                [self didReceiveData:[NSData dataWithBytes:buffer length:actuallyRead]];
            }
        } break;
        case NSStreamEventErrorOccurred:
        case NSStreamEventEndEncountered: {
            [self closeStreams];
        } break;
        default:
            break;
    }
}

- (void)startOutput
{
    [self.outputBufferLock lock];
    if ([self.outputBuffer length] == 0) {
        return;
    }
    
    NSInteger actuallyWritten = [self.outputStream write:self.outputBuffer.bytes maxLength:self.outputBuffer.length];
    
    if (actuallyWritten > 0) {
        [self.outputBuffer replaceBytesInRange:NSMakeRange(0, (NSUInteger) actuallyWritten) withBytes:NULL length:0];
        
        [self startOutput];
    } else {
        NSLog(@"CUSTOMER-DISPLAY WRITE ERROR");
        // A non-positive result from -write:maxLength: indicates a failure of some form; in this
        // simple app we respond by simply closing down our connection.
        //        [self closeStreams];
    }
    
    [self.outputBufferLock unlock];
}

- (void)writeData:(NSData*)dataToSend
{
    if (!self.isConnected) {
        return;
    }
    
    [self.outputBufferLock lock];
    
    if (self.outputBuffer != nil) {
        [self.outputBuffer appendData:dataToSend];
        BOOL isEmpty = (self.outputBuffer.length == 0);
        if (!isEmpty) {
            [self startOutput];
        }
    }
    
    [self.outputBufferLock unlock];
}

- (NSString*)displayName {
    return [self storedNameOfPos];
}

- (void)didReceiveData:(NSData *)data {
    @synchronized(self) {
        // _didReceiveData modifies dataFromPos. So, it must be thread safe (synchronized)
        [self _didReceiveData:data];
    }
}

- (void)_didReceiveData:(NSData*)data {
    NSArray *array = nil;
    
    if (self.dataFromPos == nil) {
        self.dataFromPos = [data mutableCopy];
    } else {
        [self.dataFromPos appendData:data];
    }
    
    @try {
        
        // Check the header
        if (self.dataFromPos.length < SIZE_OF_HEADER) {
            // Header not received
            // Do ntothing
            return;
        }
        
        // Header Received
        NSRange headerRange;
        headerRange.location = 0;
        headerRange.length = SIZE_OF_HEADER;
        NSData *headerData = [self.dataFromPos subdataWithRange:headerRange];
        uint64_t nLength = *((uint64_t*)headerData.bytes);
        NSNumber *dataLength = @(nLength);
        
        // Check if enough data received
//        NSLog(@"expected value = %lu",(dataLength.integerValue + SIZE_OF_HEADER));
//        NSLog(@"received value = %lu", (unsigned long)self.dataFromPos.length);

        if ((dataLength.integerValue + SIZE_OF_HEADER) > self.dataFromPos.length) {
            NSLog(@"Should read more data from POS...");
            return;
        }
        
        // We have enough data now
        NSRange dataRange;
        dataRange.location = SIZE_OF_HEADER;
        dataRange.length = dataLength.integerValue;
        
        NSData *dataPacket = [self.dataFromPos subdataWithRange:dataRange];
        
        id unarchievedObject = [NSKeyedUnarchiver unarchiveObjectWithData:dataPacket];
        
        
        
        NSLog(@"Data received = %lu", (unsigned long)array.count);
        
        // Adjust self.dataFromPos
        NSRange unprocessedDataRange;
        unprocessedDataRange.location = SIZE_OF_HEADER + dataLength.integerValue;
        unprocessedDataRange.length = self.dataFromPos.length - unprocessedDataRange.location;
        self.dataFromPos = [[self.dataFromPos subdataWithRange:unprocessedDataRange] mutableCopy];
        
        if ([unarchievedObject isKindOfClass:[NSArray class]]) {
            array = (NSArray*)unarchievedObject;
            // We have got display data for receipt
    
            
            //  append message to text box:
            dispatch_async(dispatch_get_main_queue(), ^{
                //        [self receiveMessage:message fromPeer:peerID];
            
            });
        }else if ([unarchievedObject isKindOfClass:[NSDictionary class]]) {
            // We have got the POS Name
            NSDictionary *posDictionary = (NSDictionary*)unarchievedObject;
            if (posDictionary[@"CustomerSignatureImage"]) {
                
               // UIImage *signatureImage = [posDictionary objectForKey:@"CustomerSignatureImage"];
          //      NSData *dataSignature = [posDictionary objectForKey:@"CustomerSignatureImage"];
          //      UIImage *signatureImage = [UIImage imageWithData:dataSignature];
                
                CGFloat tipsAmount = 0.00;
                
                if (posDictionary[@"TipAmount"])
                {
                    tipsAmount = [posDictionary[@"TipAmount"] floatValue];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CustomerDisplaySignatureResponse" object:posDictionary];
                        
            }
            if (posDictionary[@"IsSignatureScreenOpen"])
            {
                if ([posDictionary[@"IsSignatureScreenOpen"] isEqualToString:@"1"])
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"SignatureScreenNotification" object:posDictionary];
                }
            }
            if (posDictionary[@"IsSignatureCapturing"])
            {
                if ([posDictionary[@"IsSignatureCapturing"] isEqualToString:@"1"])
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"SignatureCapturingNotification" object:posDictionary];
                }
            }
        }
    }
    @catch (NSException *exception) {
        // Do nothing
        NSLog(@"Exception occured = %@", exception);
        NSLog(@"We shouldn't be here .... >(:-<)");
        // We are in bad state
        // Should Eject
        self.dataFromPos = [data mutableCopy];
    }
    @finally {
        // Do nothing
    }
    
    
}


@end
