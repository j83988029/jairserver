//
//  ViewController.m
//  jairserver
//
//  Created by jiangjie on 2019/10/12.
//  Copyright © 2019 app. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"APLogNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        @synchronized (self) {
            self.logTextView.string = [NSString stringWithFormat:@"%@%@\n", self.logTextView.string,note.userInfo[@"log"]];            
        }
    }];
    
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
