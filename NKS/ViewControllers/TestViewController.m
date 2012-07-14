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

- (void)sliderValueChanged:(UISlider *)slider;
- (void)reloadData;


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
    [_reloadData addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventTouchUpInside];
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
        
       // _model.pixelSize = slider.value;
        _lPixelSize.text = [NSString stringWithFormat:@"Pixel size: %d", (int)slider.value];
        
    }
}

- (void)reloadData
{
    _model.pixelSize = (int)_pixelSize.value;
}


@end
