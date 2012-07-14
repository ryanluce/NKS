//
//  GLKitViewControllerViewController.h
//  NKS
//
//  Created by Ryan Luce on 7/12/12.
//  Copyright (c) 2012 Ryan Luce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <QuartzCore/QuartzCore.h>
#import "NKSModel.h"

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

@interface GLKitViewControllerViewController : UIViewController <GLKViewDelegate>
{
    NKSModel *_model;
    GLKView *_glkView;
    GLKViewController *_glkViewController;
    GLKBaseEffect *_glkEffect;
    GLuint _colorSlot;
    GLuint _positionSlot;
    GLuint _pixelSizeSlot;
    GLuint _projectionUniform;
    GLuint _modelViewUniform;
}
@end
