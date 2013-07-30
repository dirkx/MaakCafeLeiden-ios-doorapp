//
//  AboutViewController.m
//
// Copyright © 2013 Dirk-Willem van Gulik <dirkx@webweaving.org>, all rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at:
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//


#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController
@synthesize textField;

- (void)viewDidLoad
{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"Licenses" ofType:@"txt"];
    assert(filePath);
    
    textField.text = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
 
    if(0){
    textField.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];

    for(UILabel * f in [self.view subviews])
        if ([f respondsToSelector:@selector(setTextColor:)])
            [f setTextColor:[UIColor blackColor]];
}
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(IBAction)done:(id)sender {
    [self.delegate aboutViewControllerDidFinish:self];
}
@end
