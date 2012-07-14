//
//  GLKitViewControllerViewController.m
//  NKS
//
//  Created by Ryan Luce on 7/12/12.
//  Copyright (c) 2012 Ryan Luce. All rights reserved.
//

#import "GLKitViewControllerViewController.h"
#import "ColorModel.h"

@interface GLKitViewControllerViewController ()
- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType;
- (void)compileShaders;
- (void)setupVBO;
@end

const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}},
    {{1, 1, 0}, {0, 1, 0, 1}},
    {{-1, 1, 0}, {0, 0, 1, 1}},
    {{-1, -1, 0}, {0, 0, 0, 1}}
};

@implementation GLKitViewControllerViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self compileShaders];
        [self setupVBO];
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    EAGLContext * context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2]; // 1
    _glkView = [[GLKView alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; // 2
    _glkView.context = context; // 3
    _glkView.delegate = self; // 4
    _glkViewController = [[GLKViewController alloc] init];
    _glkViewController.view = _glkView;
    _glkViewController.preferredFramesPerSecond = 1;
    [self.view addSubview:_glkView]; // 5
    glDisable(GL_POINT_SMOOTH);
    
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    NSLog(@"update");
    
    

    
    
    glClearColor(1., 0., 0., 1.);
    glClear(GL_COLOR_BUFFER_BIT);
    

    
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    
    GLKMatrix4 modelview = GLKMatrix4MakeTranslation(_model.pixelSize, _model.pixelSize, -5.f);
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelview.m);
    
    
    
    GLKMatrix4 projection = GLKMatrix4MakeOrtho(0, 768, 1024, 0, 0.1f, 20.0f);
    glUniformMatrix4fv(_projectionUniform, 1, 0, projection.m);
    
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    Vertex points[_model.rows * _model.columns];
    ColorModel *color;
    for(int i = 0; i < _model.rows; i++)
    {
        for(int ii = 0; ii < _model.columns; ii++)
        {
            color = [_model getColorAtRow:i andColumn:ii];
            Vertex v;
            v.Position[0] = ii;
            v.Position[1] = i;
            v.Position[2] = 0;
            v.Color[0] = 0;
            v.Color[1] = 1;
            v.Color[2] = 0;
            v.Color[3] = 1;
            //v.PixelSize = 20;
            points[i * _model.columns + ii] =v;
        }
    }
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(points), points, GL_STATIC_DRAW);
    
    //glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, squareVertices);
    //glVertexAttribPointer(GLKVertexAttribColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, squareColors);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 
                          sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, 
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    //glVertexAttribPointer(_pixelSizeSlot, 1, GL_FLOAT, GL_FALSE, sizeof(Vertex),(GLvoid *) (sizeof(float)*7));
    
    // 3
    
    //glDrawElements(GL_POINTS, 0, 4);
    

    //glDisableVertexAttribArray(GLKVertexAttribPosition);
    //glDisableVertexAttribArray(GLKVertexAttribColor);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setupVBO
{

    
    
}


- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    
    // 1
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName 
                                                           ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath 
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    // 2
    GLuint shaderHandle = glCreateShader(shaderType);    
    
    // 3
    const char * shaderStringUTF8 = [shaderString UTF8String];    
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 4
    glCompileShader(shaderHandle);
    
    // 5
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
    
}

- (void)compileShaders {
    
    // 1
    GLuint vertexShader = [self compileShader:@"SimpleVertex" 
                                     withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment" 
                                       withType:GL_FRAGMENT_SHADER];
    
    // 2
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    // 3
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    // 4
    glUseProgram(programHandle);
    
    // 5
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    
    
    _modelViewUniform = glGetUniformLocation(programHandle, "Modelview");
    
   
    _projectionUniform = glGetUniformLocation(programHandle, "Projection");
    
    //_pixelSizeSlot = glGetUniformLocation(programHandle, "PixelSize");
    //const GLfloat *val[] = {10.};
    
   // glUniformMatrix4fv(_pixelSizeSlot, 1, 0,  val);
    
}

@end
