//
//  RootViewController.m
//  NKS
//  Subclass of GLKViewController
//  Created by Ryan Luce on 7/5/12.
//  Copyright (c) 2012 Ryan Luce. All rights reserved.
//

#import "RootViewController.h"
#import "NKSModel.h"
#import "ColorModel.h"
#import "TestViewController.h"





@interface RootViewController () {
    GLuint _vertexBuffer;
    GLuint _program;
    GLuint _positionHandle;
    //handle for each pixels color
    GLuint _colorHandle;
    GLuint _matrixHandle;
    //in the shader a gl_PointSize is changed according to current model data
    GLuint _pixelSizeHandle;
    float _rotation;
    GLKMatrix4 _matrix;
    //Main Model
    NKSModel *_model;
    Vertex *mainVerteces;
    //Test VC is just a vc with buttons and sliders to manipulate data in the model
    TestViewController *_inputVC;
    
}

@property (readonly, nonatomic) GLKView *glkView;
@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)destroyGL;
- (GLuint)createShaderWithFile:(NSString *)filename type:(GLenum)type;
- (void)updateVertices;

@end

@implementation RootViewController



@synthesize context = _context;

- (id)init
{
    self = [super init];
    if (self) {
        //Listen for the model to call the dataUpdated function, then refresh the screen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVertices) name:@"dataUpdated" object:nil];
        //Both this vc and the testVC need access to the models data, so use singleton pattern
        _model = [NKSModel sharedInstance];    
    }
    return self;
}

#pragma mark - View lifecycle

- (void)loadView
{
    CGRect r = [[UIScreen mainScreen] bounds];
    
    self.view = [[GLKView alloc] initWithFrame:CGRectMake(0, 0, r.size.width, r.size.height)];
    
    _inputVC = [[TestViewController alloc] init];
    [self.view addSubview:_inputVC.view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self.glkView.context = self.context;
    
    [self setupGL];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self destroyGL];
    
    // Attempt to deallocate our context. The current context is retained by the setCurrentContext: call.
    // Hence, if the current context is our context, set it to nil.
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    self.context = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //using arc
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Properties

- (GLKView *)glkView
{
    return (GLKView *)self.view; // It's safe to downcast since we set a GLKView in loadView
}

#pragma mark - Methods

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    

     //Create vertex buffer
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, 1024*768*sizeof(Vertex), mainVerteces, GL_DYNAMIC_DRAW);
    
    
    // Setup shader
    GLuint vertexShader = [self createShaderWithFile:@"VertexShader.glsl" type:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self createShaderWithFile:@"FragmentShader.glsl" type:GL_FRAGMENT_SHADER];
    _program = glCreateProgram();
    
    glAttachShader(_program, vertexShader);
    glAttachShader(_program, fragmentShader);
    glLinkProgram(_program);
    
    GLint linked = 0;
    glGetProgramiv(_program, GL_LINK_STATUS, &linked);
    if (linked == 0) {
        glDeleteProgram(_program);
        return;
    }
    
    // Get handles to shader variables
    _positionHandle = glGetAttribLocation(_program, "a_position");
    _colorHandle    = glGetAttribLocation(_program, "a_color");
    _matrixHandle   = glGetUniformLocation(_program, "u_matrix");
    _pixelSizeHandle = glGetUniformLocation(_program, "u_pixelSize");
    
}

- (void)destroyGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteProgram(_program);
    _program = 0;
    
    glDeleteBuffers(1, &_vertexBuffer);
   
    _vertexBuffer = 0;
}
//just a standard function
- (GLuint)createShaderWithFile:(NSString *)filename type:(GLenum)type 
{
    GLuint shader = glCreateShader(type);
    
    if (shader == 0) {
        return 0;
    }
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
    NSString *shaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    const GLchar *shaderSource = [shaderString cStringUsingEncoding:NSUTF8StringEncoding];
    
    glShaderSource(shader, 1, &shaderSource, NULL);
    glCompileShader(shader);
    
    GLint success = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
    
    if (success == 0) {
        char errorMsg[2048];
        glGetShaderInfoLog(shader, sizeof(errorMsg), NULL, errorMsg);
        NSString *errorString = [NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding];
        NSLog(@"Failed to compile %@: %@", filename, errorString);
        glDeleteShader(shader);
        return 0;
    }
    
    return shader;
}

- (void)update
{
    _rotation += (M_PI/6)*self.timeSinceLastUpdate;
    float width = self.glkView.drawableWidth/self.glkView.contentScaleFactor;
    float height = self.glkView.drawableHeight/self.glkView.contentScaleFactor;
    
   //GLKMatrix4 rotation = GLKMatrix4MakeRotation(_rotation, 0, 0, 1);
    GLKMatrix4 scale = GLKMatrix4MakeScale(_model.pixelSize,_model.pixelSize, 1.);
    GLKMatrix4 translation = GLKMatrix4MakeTranslation(_model.pixelSize/2, _model.pixelSize/2, 0);
    GLKMatrix4 projection = GLKMatrix4MakeOrtho(0.f, width, height, 0, -100.f, 100.f);
    _matrix = GLKMatrix4Multiply(GLKMatrix4Multiply(projection, translation), scale);
}

#pragma mark - GLKViewDelegate
//Draw All the data that's in the model
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.5, 0.5, 0.6, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    
    glUseProgram(_program);
    glUniformMatrix4fv(_matrixHandle, 1, GL_FALSE, _matrix.m);
    glUniform1f(_pixelSizeHandle, _model.pixelSize);

    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glEnableVertexAttribArray(_positionHandle);
    glVertexAttribPointer(_positionHandle, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void *)offsetof(Vertex, position));
    glEnableVertexAttribArray(_colorHandle);
    glVertexAttribPointer(_colorHandle, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void *)offsetof(Vertex, color));
    

    glDrawArrays(GL_POINTS, 0, _model.rows * _model.columns);
    
#ifdef DEBUG
    GLenum error = glGetError();
    if (error != GL_NO_ERROR) {
        NSLog(@"OpenGL error: %d", error);
    }
#endif
}

- (void)updateVertices
{
    //release the old data
    free(mainVerteces);
    //malloc a Vertex struct for each point on the screen
    mainVerteces = malloc(1024 * 768 * sizeof(Vertex)); 
    memset(mainVerteces, 0, 1024 * 768);
    
    //loop through each pixel and assign position and color attributes
    for(int i = 0; i < _model.rows; i++)
    {
        for (int ii = 0; ii < _model.columns; ii++) {
            //using a 1 dimensional array of int type, so treat it as if it were multidimensional
            int index = (i * _model.columns) + ii; 
            //x, y, z
            mainVerteces[index].position[0] = ii;
            mainVerteces[index].position[1] = i; 
            mainVerteces[index].position[2] = 0;
            
            //Probably refactor this into a struct
            ColorModel *c = [_model getColorAtRow:i andColumn:ii];
            //r,g,b
            mainVerteces[index].color[0] = c.red;
            mainVerteces[index].color[1] = c.green;
            mainVerteces[index].color[2] = c.blue;
            mainVerteces[index].color[3] = 1.0;

        }
        
    }

    //all the magic happens here
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, _model.rows*_model.columns* sizeof(Vertex), mainVerteces, GL_DYNAMIC_DRAW);
   
}

	
@end
