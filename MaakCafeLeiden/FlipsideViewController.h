//
//  FlipsideViewController.h
//  MaakCafeLeiden
//
// Copyright © 2013 Dirk-Willem van Gulik <dirkx@webweaving.org>, all rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at:
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//

#import <UIKit/UIKit.h>
#import "AboutViewController.h"

@class FlipsideViewController;

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

@interface FlipsideViewController : UIViewController <AboutViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UILabel * copyrightLabel;
@property (strong, nonatomic) IBOutlet UILabel * appLabel;

@property (strong, nonatomic) IBOutlet UISwitch * doorNotificationsSwitch;
@property (strong, nonatomic) IBOutlet UISwitch * doorNotificationsSoundSwitch;
@property (strong, nonatomic) IBOutlet UISwitch * doorNotificationsAlertSwitch;

@property (strong, nonatomic) IBOutlet UISwitch * doorNotificationsDistanceSwitch;
@property (strong, nonatomic) IBOutlet UISlider * doorNotificationDistanceSlider;
@property (strong, nonatomic) IBOutlet UILabel  * doorNotificationDistanceLabel;
@property (strong, nonatomic) IBOutlet UILabel  * doorNotificationDistanceMainText;

@property (strong, nonatomic) IBOutlet UISwitch * proximityDistanceSwitch;
@property (strong, nonatomic) IBOutlet UISlider * proximityDistanceSlider;
@property (strong, nonatomic) IBOutlet UILabel  * proximityDistanceLabel;

@property (strong, nonatomic) IBOutlet UISwitch * activitySoundSwitch;

@property (weak, nonatomic) id <FlipsideViewControllerDelegate> delegate;

- (IBAction)switchChangedNotify:(id)sender;

- (IBAction)doorNotificationSliderChange:(id)sender;
- (IBAction)proximitySliderChange:(id)sender;

- (IBAction)done:(id)sender;
@end
