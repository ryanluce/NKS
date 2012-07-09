//
//  TestViewController.m
//  NKS
//
//  Created by Ryan Luce on 7/5/12.
//  Copyright (c) 2012 Ryan Luce. All rights reserved.
//

#import "TestViewController.h"
#import "ColorModel.h"


@interface TestViewController()

- (void)drawRectWithRect:(CGRect)rect withColor:(ColorModel *)color;

@end

@implementation TestViewController

- (id)init
{
    if(self = [super init])
    {
        _model = [NKSModel sharedInstance];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    GLKView *glkView = (GLKView *)self.view;
    glkView.delegate = self;
    glkView.context = aContext;
    
    glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    glkView.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    glkView.drawableMultisample = GLKViewDrawableMultisample4X;
    
    self.delegate = self;
    self.preferredFramesPerSecond = 30;
    
    effect = [[GLKBaseEffect alloc] init];
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f); 
    
    UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:_model action:@selector(reloadData)];
    [self.view addGestureRecognizer:t];
}

- (void)glkViewControllerUpdate:(GLKViewController *)controller
{
    
    static float transY = 0.0f;
    float y = sinf(transY)/2.0f;
    transY += 0.175f;
    
    GLKMatrix4 modelview = GLKMatrix4MakeTranslation(0, y, -5.0f);
    effect.transform.modelviewMatrix = modelview;
    
    //GLfloat ratio = self.view.bounds.size.width/self.view.bounds.size.height;
    GLKMatrix4 projection = GLKMatrix4MakeOrtho(0, 768, 1024, 0, 0.1f, 20.0f);    
    effect.transform.projectionMatrix = projection;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT);
    [effect prepareToDraw];
    int pixelSize = _model.pixelSize;
    if(!_model.isReady)
        return;
    for(int i = 0; i < _model.rows; i++)
    {
        for(int ii = 0; ii < _model.columns; ii++)
        {
            ColorModel *color = [_model getColorAtRow:i andColumn:ii];
            CGRect rect = CGRectMake(ii * pixelSize, i*pixelSize, pixelSize, pixelSize);
            //[self drawRectWithRect:rect withColor:c];
            GLubyte squareColors[] = {
                color.red, color.green, color.blue, 255,
                color.red, color.green, color.blue, 255,
                color.red, color.green, color.blue, 255,
                color.red, color.green, color.blue, 255
            };
            
            // NSLog(@"Drawing color with red: %d", color.red);
            
            
            int xVal = rect.origin.x;
            int yVal = rect.origin.y;
            int width = rect.size.width;
            int height = rect.size.height;
            GLfloat squareVertices[] = {
                xVal, yVal, 1,
                xVal + width, yVal, 1,
                xVal,  yVal + height, 1,
                xVal + width,  yVal + height, 1
            };    
            
            glEnableVertexAttribArray(GLKVertexAttribPosition);
            glEnableVertexAttribArray(GLKVertexAttribColor);
            
            glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, squareVertices);
            glVertexAttribPointer(GLKVertexAttribColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, squareColors);
            
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            
            glDisableVertexAttribArray(GLKVertexAttribPosition);
            glDisableVertexAttribArray(GLKVertexAttribColor);
            

        }
    }
    
    
}

- (void)drawRectWithRect:(CGRect)rect withColor:(ColorModel *)color
{

}


@end
