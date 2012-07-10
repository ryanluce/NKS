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
- (void)sliderValueChanged:(UISlider *)slider;


@end

@implementation TestViewController

- (id)init
{
    if(self = [super init])
    {
        
        _model = [NKSModel sharedInstance];
        _isOpenGLViewReady = NO;        
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
    
    //UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:_model action:@selector(reloadData)];
    //[self.view addGestureRecognizer:t];
    
    int yOffset = 700;
    
    _numberOfNeighbors= [[UISlider alloc] initWithFrame:CGRectMake(200, yOffset, 200, 60)];
    _numberOfNeighbors.value = 1;
    _numberOfNeighbors.minimumValue = 1;
    _numberOfNeighbors.maximumValue = 3;
    [_numberOfNeighbors addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    _lNeighbors = [[UILabel alloc] initWithFrame:CGRectMake(10, yOffset, 200, 60)];
    _lNeighbors.textColor = [UIColor whiteColor];
    _lNeighbors.text = @"Neighbors: 1";
    _lNeighbors.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:_numberOfNeighbors];
    [self.view addSubview:_lNeighbors];
    
    yOffset +=80;
    
    _numberOfColors= [[UISlider alloc] initWithFrame:CGRectMake(200, yOffset, 200, 60)];
    _numberOfColors.value = 2;
    _numberOfColors.minimumValue = 2;
    _numberOfColors.maximumValue = 10;
    [_numberOfColors addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    _lColors = [[UILabel alloc] initWithFrame:CGRectMake(10, yOffset, 200, 60)];
    _lColors.textColor = [UIColor whiteColor];
    _lColors.text = @"Colors: 2"; 
    _lColors.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:_numberOfColors];
    [self.view addSubview:_lColors];
    
    yOffset +=80;   
    
    _pixelSize= [[UISlider alloc] initWithFrame:CGRectMake(200, yOffset, 200, 60)];
    _pixelSize.value = 2;
    _pixelSize.minimumValue = 2;
    _pixelSize.maximumValue = 20;
    [_pixelSize addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    _lPixelSize = [[UILabel alloc] initWithFrame:CGRectMake(10, yOffset, 200, 60)];
    _lPixelSize.textColor = [UIColor whiteColor];
    _lPixelSize.text = @"Pixel Size: 2"; 
    _lPixelSize.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:_pixelSize];
    [self.view addSubview:_lPixelSize];
    
    yOffset +=80;   

    
    _reloadData = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_reloadData setTitle:@"Reload" forState:UIControlStateNormal];
    [_reloadData addTarget:_model action:@selector(reloadData) forControlEvents:UIControlEventTouchUpInside];
    _reloadData.frame = CGRectMake(10, yOffset, 150, 60);
    [self.view addSubview:_reloadData];
    
    
}

- (void)sliderValueChanged:(UISlider *)slider
{
    slider.value = (int)slider.value;
    slider.continuous = YES;
    if(slider == _numberOfNeighbors)
    {
        _model.totalNeighborCount = slider.value;
        _lNeighbors.text = [NSString stringWithFormat:@"Neighbors: %d", (int)slider.value];
        
    } else if(slider == _numberOfColors)
    {
        _model.numberOfRules = slider.value;
        _lColors.text = [NSString stringWithFormat: @"Colors: %d", (int)slider.value];
        
    } else if(slider == _pixelSize)
    {
        
        _model.pixelSize = slider.value;
        _lPixelSize.text = [NSString stringWithFormat:@"Pixel size: %d", (int)slider.value];
        
    }
}

- (void)glkViewControllerUpdate:(GLKViewController *)controller
{
    
    //static float transY = 0.0f;
    //float y = sinf(transY)/2.0f;
    //transY += 0.175f;
    
    GLKMatrix4 modelview = GLKMatrix4MakeTranslation(0, 0, -5.f);
    effect.transform.modelviewMatrix = modelview;
    
    //GLfloat ratio = self.view.bounds.size.width/self.view.bounds.size.height;
    GLKMatrix4 projection = GLKMatrix4MakeOrtho(0, 768, 1024, 0, 0.1f, 20.0f);    
    effect.transform.projectionMatrix = projection;
    _isOpenGLViewReady = YES;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    if(_model.updateView && _isOpenGLViewReady)
    {
        
        glClear(GL_COLOR_BUFFER_BIT);
        [effect prepareToDraw];
        int pixelSize = _model.pixelSize;
        if(!_model.isReady)
            return;
        //NSLog(@"UPDATING: %d, %d", _model.rows, _model.columns);
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
        _model.updateView = YES;
    }

    
    
}

- (void)drawRectWithRect:(CGRect)rect withColor:(ColorModel *)color
{

}


@end
