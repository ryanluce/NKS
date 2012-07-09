//
//  TestViewController.h
//  NKS
//
//  Created by Ryan Luce on 7/5/12.
//  Copyright (c) 2012 Ryan Luce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "NKSModel.h"

@interface TestViewController : GLKViewController <GLKViewControllerDelegate, GLKViewDelegate>
{
    GLKBaseEffect *effect;
    NKSModel *_model;
}
@end
