//
//  RASDetailViewController.h
//  AlertProject
//
//  Created by Ekaterina Kondareva on 11/27/12.
//  Copyright (c) 2012 Ekaterina Kondareva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Foundation/Foundation.h>
#import "RASHistoryViewController.h"
#import <QuartzCore/QuartzCore.h>

@class DetailViewController;
@class Device;

@interface RASDetailViewController : UIViewController <UISplitViewControllerDelegate, MFMailComposeViewControllerDelegate>
{
  BOOL IsPriorityHigh;
}

@property (strong, nonatomic) RASDetailViewController *detailViewController;
@property (strong, nonatomic) LoginViewController *loginViewController;

@property (strong, nonatomic) RASHistoryViewController *historyViewController;

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UIView *view1;
@property (strong, nonatomic) IBOutlet UIView *view2;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *sensorText;
@property (nonatomic, retain) NSString *sensor;

@property (strong, nonatomic) IBOutlet UILabel *deviceIdText;
@property (nonatomic, retain) NSString *deviceID;

@property (nonatomic, retain) NSString *nickNameText;

@property (weak, nonatomic) IBOutlet UILabel *statusText;
@property (nonatomic, retain) NSString *status;

@property (weak, nonatomic) IBOutlet UILabel *timeText;
@property (nonatomic, retain) NSString *time;

@property (weak, nonatomic) IBOutlet UILabel *switchLabel; 
@property (weak, nonatomic) IBOutlet UISwitch *high_low;

@property (weak, nonatomic) IBOutlet UISwitch *emailNotification;

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UITextField *nickNameTextField;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *logoutButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *changesButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *EmailButton;

@property (nonatomic, retain) UIActivityIndicatorView *myIndicator;

@property(nonatomic) BOOL isPriorityOn;
@property(nonatomic) BOOL isEmailOn;


// @property (nonatomic, retain) IBOutlet UIBarButtonItem *SeeHistoryButton;


- (IBAction)logoutPressed:(id)sender;
- (IBAction)saveChangesPressed:(id)sender;
- (IBAction)emailButtonPressed:(id)sender;

- (IBAction)SeeHistoryButtonPressed;


@end
