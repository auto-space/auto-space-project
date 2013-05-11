//
//  TableViewController.h
//  SimpleControl
//
//  Created by Raphael on 5/8/13.
//

#import <UIKit/UIKit.h>
#import "BLE.h"
@interface TableViewController : UITableViewController <BLEDelegate>
{
    IBOutlet UIButton *btnConnect;
    IBOutlet UISwitch *swDigitalOut;
    IBOutlet UISlider *sldPWM;
    IBOutlet UIActivityIndicatorView *indConnecting;
    IBOutlet UILabel *lblRSSI;
}

@property (strong, nonatomic) BLE *ble;

@end
