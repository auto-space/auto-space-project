//
//  TableViewController.h
//  SimpleControl
//
//  Created by Raphael on 5/8/13.
//

#import "TableViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController

@synthesize ble;


- (void)viewDidLoad
{
    [super viewDidLoad];

    ble = [[BLE alloc] init];
    [ble controlSetup:1];
    ble.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - BLE delegate

- (void)bleDidDisconnect
{
    NSLog(@"->Disconnected");

    [btnConnect setTitle:@"连接" forState:UIControlStateNormal];
    [indConnecting stopAnimating];
    
    swDigitalOut.enabled = false;
    sldPWM.enabled = false;
    
    lblRSSI.text = @"---";
}

// When RSSI is changed, this will be called
-(void) bleDidUpdateRSSI:(NSNumber *) rssi
{
    lblRSSI.text = rssi.stringValue;
}

// When disconnected, this will be called
-(void) bleDidConnect
{
    NSLog(@"->Connected");

    [indConnecting stopAnimating];
    
    swDigitalOut.enabled = true;
    sldPWM.enabled = true;
    
    swDigitalOut.on = false;
    sldPWM.value = 0;
}

-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSLog(@"Length: %d", length);
}

#pragma mark - Actions

// Connect button will call to this
- (IBAction)btnScanForPeripherals:(id)sender
{
    if (ble.activePeripheral)
        if(ble.activePeripheral.isConnected)
        {
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
            [btnConnect setTitle:@"连接" forState:UIControlStateNormal];
            return;
        }
    
    if (ble.peripherals)
        ble.peripherals = nil;
    
    [btnConnect setEnabled:false];
    [ble findBLEPeripherals:2];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    [indConnecting startAnimating];
}

-(void) connectionTimer:(NSTimer *)timer
{
    [btnConnect setEnabled:true];
    [btnConnect setTitle:@"断开" forState:UIControlStateNormal];
    
    if (ble.peripherals.count > 0)
    {
        [ble connectPeripheral:[ble.peripherals objectAtIndex:0]];
    }
    else
    {
        [btnConnect setTitle:@"连接" forState:UIControlStateNormal];
        [indConnecting stopAnimating];
    }
}

-(IBAction)sendDigitalOut:(id)sender
{
    UInt8 buf[3] = {0x01, 0x00, 0x00};
    
    if (swDigitalOut.on)
        buf[1] = 0x01;
    else
        buf[1] = 0x00;
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
}


// PWM slide will call this to send its value to Arduino
-(IBAction)sendPWM:(id)sender
{
    UInt8 buf[3] = {0x02, 0x00, 0x00};
    
    buf[1] = sldPWM.value;
    buf[2] = (int)sldPWM.value >> 8;
    
    NSLog(@"%c, %c, %c", buf[0], buf[1], buf[2]);
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    NSLog(@"%@", data);
    [ble write:data];
}

@end
