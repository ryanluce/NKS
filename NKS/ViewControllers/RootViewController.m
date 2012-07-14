//
//  RootViewController.m
//  GLKSample
//
//  Created by xiss burg on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "NKSModel.h"
#import "ColorModel.h"
#import "TestViewController.h"

/**
 * Vertex data structure.
 */




@interface RootViewController () {
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    GLuint _program;
    GLuint _positionHandle;
    GLuint _colorHandle;
    GLuint _matrixHandle;
    GLuint _pixelSizeHandle;
    float _rotation;
    GLKMatrix4 _matrix;
    NKSModel *_model;
    Vertex mainVerteces[1024*768];
    GLubyte mainIndices[1024*768];
    
    TestViewController *_inputVC;
    
    //Vertex vertices;
   // GLubyte indices;
}

@property (readonly, nonatomic) GLKView *glkView;
@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)destroyGL;
- (GLuint)createShaderWithFile:(NSString *)filename type:(GLenum)type;
- (void)updateVertices;

@end

@implementation RootViewController

const Vertex vertices[1024*768];
const GLubyte indices[1024*768];

@synthesize context = _context;

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVertices) name:@"dataUpdated" object:nil];
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
    
    for (int i = 0; i < 768*1024; i++) {
        mainIndices[i] = i;
    }
    
    // Create vertex buffer
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(mainVerteces), mainVerteces, GL_DYNAMIC_DRAW);
    
    // Create index buffer
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(mainIndices), mainIndices, GL_STATIC_DRAW);
    
    
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
    glDeleteBuffers(1, &_indexBuffer);
    _vertexBuffer = _indexBuffer = 0;
}

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
    
    //glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    //glDrawElements(GL_POINTS, sizeof(mainIndices)/sizeof(mainIndices[0]), GL_UNSIGNED_BYTE, 0);
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
    NSLog(@"updating vertices %d", _model.rows);
    for(int i = 0; i < _model.rows; i++)
    {
        for (int ii = 0; ii < _model.columns; ii++) {
            int index = (i * _model.columns) + ii; 
            mainVerteces[index].position[0] = ii;
            mainVerteces[index].position[1] = i; 
            mainVerteces[index].position[2] = 0;
            ColorModel *c = [_model getColorAtRow:i andColumn:ii];
            //NSLog(@"color %f", c.red);
            mainVerteces[index].color[0] = c.red;
            mainVerteces[index].color[1] = c.green;
            mainVerteces[index].color[2] = c.blue;
            mainVerteces[index].color[3] = 1.0;
            //NSLog(@"mainvertices[%d] x,y %f, %f", index, mainVerteces[index].position[0], mainVerteces[index].position[1]);
            //mainIndices[index] = index;
        }
        
    }
    
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(mainVerteces), mainVerteces, GL_STATIC_DRAW);
    //glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(mainVerteces), mainVerteces);
   /* glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(mainIndices), mainIndices, GL_STATIC_DRAW);
    
    for(int nslogger = 0; nslogger < 3; nslogger++)
    {
        NSLog(@"mainVerteces[%d].position[%d] = %f", 0, nslogger, mainVerteces[1000].color[nslogger]);
    }*/
}
@end
