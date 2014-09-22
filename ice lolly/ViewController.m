//
//  ViewController.m
//  ice lolly
//
//  Created by Ian Meyer on 9/20/14.
//  Copyright (c) 2014 frijole. All rights reserved.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "TargetConditionals.h"

#import "UILabel+Shake.h"

// for camera
static void *CapturingStillImageContext = &CapturingStillImageContext;
static void *RecordingContext = &RecordingContext;
static void *SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

static void *FocusModeContext = &FocusModeContext;
static void *ExposureModeContext = &ExposureModeContext;
static void *LensPositionContext = &LensPositionContext;
static void *ExposureDurationContext = &ExposureDurationContext;
static void *ISOContext = &ISOContext;
// end camera stuff

@interface ViewController () <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic) NSArray *isoValues;
@property (nonatomic) NSInteger currentISO;

@property (nonatomic) NSArray *shutterLabelValues;
@property (nonatomic) NSInteger currentShutterDuration;

- (void)increaseISO;
- (void)decreaseISO;

- (void)increaseShutterDuration;
- (void)decreaseShutterDuration;

// for camera
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureDevice *videoDevice;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;
// end camera stuff

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    for ( UIView *tmpContainer in @[self.isoContainer, self.shutterContainer] ) {
        [tmpContainer.layer setCornerRadius:7.0f];
        [tmpContainer.layer setBorderWidth:1.0f];
        [tmpContainer.layer setBorderColor:[UIColor colorWithWhite:1.0f alpha:0.3f].CGColor];
        [tmpContainer setClipsToBounds:YES];
        
        [tmpContainer setAlpha:0.75f];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged) name:UIDeviceOrientationDidChangeNotification object:nil];

#if TARGET_IPHONE_SIMULATOR
    return;
#endif
    
    [self setupCamera];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    dispatch_async([self sessionQueue], ^{
        [self addObservers];
        
        [[self session] startRunning];
    });
}

- (void)viewDidDisappear:(BOOL)animated
{
    dispatch_async([self sessionQueue], ^{
        [[self session] stopRunning];
        
        [self removeObservers];
    });
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)swipeUp:(id)sender {
    UIDeviceOrientation tmpDeviceOrientation = [[UIDevice currentDevice] orientation];
    switch ( tmpDeviceOrientation ) {
        case UIDeviceOrientationLandscapeLeft:
            [self decreaseShutterDuration]; // left, dimmer
            break;
        case UIDeviceOrientationLandscapeRight:
            [self increaseShutterDuration]; // right, brighter
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            [self decreaseISO]; // dimmer, shorter
            break;
        default:
            [self increaseISO]; // brighter, longer
            break;
    }
}

- (IBAction)swipeDown:(id)sender {
    UIDeviceOrientation tmpDeviceOrientation = [[UIDevice currentDevice] orientation];
    switch ( tmpDeviceOrientation ) {
        case UIDeviceOrientationLandscapeLeft:
            [self increaseShutterDuration]; // right, brighter
            break;
        case UIDeviceOrientationLandscapeRight:
            [self decreaseShutterDuration]; // left, dimmer
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            [self increaseISO]; // up, brighter, longer
            break;
        default:
            [self decreaseISO]; // down, dimmer, shorter
            break;
    }
}

- (IBAction)swipeLeft:(id)sender {
    UIDeviceOrientation tmpDeviceOrientation = [[UIDevice currentDevice] orientation];
    switch ( tmpDeviceOrientation ) {
        case UIDeviceOrientationLandscapeLeft:
            [self decreaseISO]; // down, dimmer
            break;
        case UIDeviceOrientationLandscapeRight:
            [self increaseISO]; // up, brighter
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            [self increaseShutterDuration]; // right, brighter, moar
            break;
        default:
            [self decreaseShutterDuration]; // left, dimmer, less
            break;
    }
}

- (IBAction)swipeRight:(id)sender {
    UIDeviceOrientation tmpDeviceOrientation = [[UIDevice currentDevice] orientation];
    switch ( tmpDeviceOrientation ) {
        case UIDeviceOrientationLandscapeLeft:
            [self increaseISO]; // up, brighter
            break;
        case UIDeviceOrientationLandscapeRight:
            [self decreaseISO]; // down, dimmer
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            [self decreaseShutterDuration]; // left, dimmer, less
            break;
        default:
            [self increaseShutterDuration]; // right, brighter, moar
            break;
    }
}

- (void)deviceOrientationChanged
{
    UIDeviceOrientation toDeviceOrientation = [[UIDevice currentDevice] orientation];
    
    CGFloat tmpRotation = 0.0f;
    switch ( toDeviceOrientation ) {
        case UIDeviceOrientationLandscapeLeft:
            tmpRotation = M_PI_2;
            break;
        case UIDeviceOrientationLandscapeRight:
            tmpRotation = -M_PI_2;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            tmpRotation = M_PI;
            break;
        default:
            tmpRotation = 0.0f;
            break;
    }
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         CGAffineTransform tmpTransform = CGAffineTransformMakeRotation(tmpRotation);
                         [self.isoContainer setTransform:tmpTransform];
                         [self.shutterContainer setTransform:tmpTransform];
                     }];
}

#pragma mark - Overrides
- (NSArray *)isoValues {
    return _isoValues?:@[@"50", @"100", @"200", @"400", @"800", @"1600"];
}

- (void)setCurrentISO:(NSInteger)newISO
{
    NSError *error = nil;

    if ( [self.isoValues indexOfObject:[NSString stringWithFormat:@"%@", @(newISO)]] == NSNotFound ) {
        error = [[NSError alloc] initWithDomain:@"info.frijole.lollipop" code:42 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"New ISO Value (%@) is not one of the available ISO values (%@)",@(newISO),self.isoValues]}];
    }
    if ( !error && [self.videoDevice lockForConfiguration:&error] ) {
        CGFloat tmpShutterDurationSeconds = 1.0f/self.currentShutterDuration;
        [self.videoDevice setExposureModeCustomWithDuration:CMTimeMakeWithSeconds(tmpShutterDurationSeconds, 1000*1000*1000)
                                                        ISO:newISO
                                          completionHandler:nil];
        [self.videoDevice unlockForConfiguration];
    }

    if ( error ) {
        NSLog(@"%@", error);
    } else {
        _currentISO = newISO;
    }
}

- (void)setMinimumISO:(CGFloat)minISO andMaximumISO:(CGFloat)maxISO {
    self.isoValues = nil;
    NSMutableArray *tmpISOValuesCopy = self.isoValues.mutableCopy;
    for ( NSString *tmpISOValue in self.isoValues ) {
        if ( tmpISOValue.floatValue < minISO || tmpISOValue.floatValue > maxISO ) {
            [tmpISOValuesCopy removeObject:tmpISOValue];
        }
    }
    [self setIsoValues:[NSArray arrayWithArray:tmpISOValuesCopy]];
    // TODO: update label
}

- (NSArray *)shutterLabelValues {
    return _shutterLabelValues?:@[@"1", @"2", @"4", @"8", @"15", @"30", @"60", @"125", @"250", @"500", @"1000"];
}

- (void)setCurrentShutterDuration:(NSInteger)newShutterDuration
{
    NSError *error = nil;
    
    if ( [self.shutterLabelValues indexOfObject:[NSString stringWithFormat:@"%@", @(newShutterDuration)]] == NSNotFound ) {
        error = [[NSError alloc] initWithDomain:@"info.frijole.lollipop" code:42 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"New Shutter Duration (%@) is not one of the available shutter duration values (%@)",@(newShutterDuration),self.shutterLabelValues]}];
    }
    if ( !error && [self.videoDevice lockForConfiguration:&error] ) {
        CGFloat newDurationSeconds = 1.0f/newShutterDuration;
        [self.videoDevice setExposureModeCustomWithDuration:CMTimeMakeWithSeconds(newDurationSeconds, 1000*1000*1000)
                                                        ISO:self.currentISO?:AVCaptureISOCurrent
                                          completionHandler:nil];
        [self.videoDevice unlockForConfiguration];
    }
    
    if ( error ) {
        NSLog(@"%@", error);
    }
    else {
        _currentShutterDuration = newShutterDuration;
    }
}

- (void)setMinimumShutterDuration:(CGFloat)minShutterDuration andMaximumShutterDuration:(CGFloat)maxShutterDuration {
    self.shutterLabelValues = nil;
    NSMutableArray *tmpShutterLabelsCopy = self.shutterLabelValues.mutableCopy;
    for ( NSString *tmpShutterLabel in self.shutterLabelValues ) {
        CGFloat tmpShutterDuration = 1.0f/tmpShutterLabel.floatValue;
        if ( tmpShutterDuration < minShutterDuration || tmpShutterDuration > maxShutterDuration ) {
            [tmpShutterLabelsCopy removeObject:tmpShutterLabel];
        }
    }
    [self setShutterLabelValues:[NSArray arrayWithArray:tmpShutterLabelsCopy]];
    // TODO: update label
}

#pragma mark - Adjustments
- (void)increaseISO {
    if ( [self.isoLabel.text isEqualToString:self.isoValues.lastObject] ) {
        [self.isoLabel shakeDown];
        return;
    }
    
    // find current and new iso
    NSInteger tmpCurrentISOIndex = [self.isoValues indexOfObject:self.isoLabel.text];
    NSString *tmpNewISO = @"";
    if ( tmpCurrentISOIndex != NSNotFound ) {
        tmpNewISO = self.isoValues[tmpCurrentISOIndex+1];
    } else {
        tmpNewISO = self.isoValues.lastObject;
    }
    
    // update ISO
    [self setCurrentISO:tmpNewISO.integerValue];
    
    // update label
    [UIView transitionWithView:self.isoLabel
                      duration:0.25f
                       options:UIViewAnimationOptionTransitionFlipFromTop
                    animations:^{
                        [self.isoLabel setText:tmpNewISO];
                    }
                    completion:nil];
}

- (void)decreaseISO {
    if ( [self.isoLabel.text isEqualToString:self.isoValues.firstObject] ) {
        [self.isoLabel shakeUp];
        return;
    }
    
    // find current and new iso
    NSInteger tmpCurrentISOIndex = [self.isoValues indexOfObject:self.isoLabel.text];
    NSString *tmpNewISO = @"";
    if ( tmpCurrentISOIndex != NSNotFound ) {
        tmpNewISO = self.isoValues[tmpCurrentISOIndex-1];
    } else {
        tmpNewISO = self.isoValues.firstObject;
    }

    // update ISO
    [self setCurrentISO:tmpNewISO.integerValue];
    
    // update label
    [UIView transitionWithView:self.isoLabel
                      duration:0.25f
                       options:UIViewAnimationOptionTransitionFlipFromBottom
                    animations:^{
                        [self.isoLabel setText:tmpNewISO];
                    }
                    completion:nil];
}

- (void)increaseShutterDuration {
    if ( [self.shutterLabel.text isEqualToString:self.shutterLabelValues.firstObject] ) {
        [self.shutterLabel shakeLeft];
        return;
    }

    // find current and new shutter
    NSInteger tmpCurrentShutterIndex = [self.shutterLabelValues indexOfObject:self.shutterLabel.text];
    NSString *tmpNewShutterLabel = @"";
    if ( tmpCurrentShutterIndex != NSNotFound ) {
        tmpNewShutterLabel = self.shutterLabelValues[tmpCurrentShutterIndex-1];
    } else {
        // wat?!
        tmpNewShutterLabel = self.shutterLabelValues.lastObject;
    }
    
    // update shutter duration
    [self setCurrentShutterDuration:tmpNewShutterLabel.integerValue];
    
    // update label
    [UIView transitionWithView:self.shutterLabel
                      duration:0.25f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        [self.shutterLabel setText:tmpNewShutterLabel];
                    }
                    completion:nil];}

- (void)decreaseShutterDuration {
    if ( [self.shutterLabel.text isEqualToString:self.shutterLabelValues.lastObject] ) {
        [self.shutterLabel shakeRight];
        return;
    }
    
    // find current and new shutter
    NSInteger tmpCurrentShutterIndex = [self.shutterLabelValues indexOfObject:self.shutterLabel.text];
    NSString *tmpNewShutterLabel = @"";
    if ( tmpCurrentShutterIndex != NSNotFound ) {
        tmpNewShutterLabel = self.shutterLabelValues[tmpCurrentShutterIndex+1];
    } else {
        tmpNewShutterLabel = self.shutterLabelValues.firstObject;
    }
    
    // update shutter duration
    [self setCurrentShutterDuration:tmpNewShutterLabel.integerValue];

    // update label
    [UIView transitionWithView:self.shutterLabel
                      duration:0.25f
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        [self.shutterLabel setText:tmpNewShutterLabel];
                    }
                    completion:nil];
}

#pragma mark - Camera
- (void)setupCamera {
    // Create the AVCaptureSession
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [self setSession:session];
    
    // Set up preview
    [[self previewView] setSession:session];
    
    // Check for device authorization
    [self checkDeviceAuthorizationStatus];
    
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
    
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue];
    
    dispatch_async(sessionQueue, ^{
        [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
        
        NSError *error = nil;
        
        AVCaptureDevice *videoDevice = [ViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (error) {
            NSLog(@"%@", error);
        }
        
        [[self session] beginConfiguration];
        
        if ([session canAddInput:videoDeviceInput]) {
            [session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
            [self setVideoDevice:videoDeviceInput.device];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Why are we dispatching this to the main queue?
                // Because AVCaptureVideoPreviewLayer is the backing layer for our preview view and UIView can only be manipulated on main thread.
                // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                AVCaptureVideoPreviewLayer *tmpPreviewLayer = (AVCaptureVideoPreviewLayer *)[[self previewView] layer];
                [tmpPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
                
                [self.previewView setClipsToBounds:YES];
            });
        }
        
        AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
        AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        
        if (error) {
            NSLog(@"%@", error);
        }
        
        if ([session canAddInput:audioDeviceInput]) {
            [session addInput:audioDeviceInput];
        }
        
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ([session canAddOutput:movieFileOutput]) {
            [session addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if ([connection isVideoStabilizationSupported]) {
                // TODO: UPDATE (?)
                [connection setEnablesVideoStabilizationWhenAvailable:YES];
            }
            [self setMovieFileOutput:movieFileOutput];
        }
        
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([session canAddOutput:stillImageOutput]) {
            [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
            [session addOutput:stillImageOutput];
            [self setStillImageOutput:stillImageOutput];
        }
        
        [[self session] commitConfiguration];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // [self updateLabels];
            // [self updateSlider];
            
            float tmpMinISO = self.videoDevice.activeFormat.minISO;
            float tmpMaxISO = self.videoDevice.activeFormat.maxISO;
            float tmpMinExposure = CMTimeGetSeconds(self.videoDevice.activeFormat.minExposureDuration);
            float tmpMaxExposure = CMTimeGetSeconds(self.videoDevice.activeFormat.maxExposureDuration);
            
            [self setMinimumISO:tmpMinISO andMaximumISO:tmpMaxISO];
            [self setMinimumShutterDuration:tmpMinExposure andMaximumShutterDuration:tmpMaxExposure];
            
            [self setAutoExposureEnabled:NO];
            
            NSError *tmpError;
            [self.videoDevice lockForConfiguration:&tmpError];
            if ( !tmpError ) {
                _currentShutterDuration = self.shutterLabel.text.integerValue;
                _currentISO = self.isoLabel.text.integerValue;
                [self.videoDevice setExposureModeCustomWithDuration:CMTimeMakeWithSeconds(1.0f/_currentShutterDuration, 1000*1000*1000) ISO:_currentISO completionHandler:nil];
                if ( [self.videoDevice isSmoothAutoFocusSupported] ) {
                    [self.videoDevice setSmoothAutoFocusEnabled:YES];
                }
                [self.videoDevice unlockForConfiguration];
            }
        });
    });
}

- (void)checkDeviceAuthorizationStatus {
    NSString *mediaType = AVMediaTypeVideo;
    
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if (granted) {
            [self setDeviceAuthorized:YES];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"AVCamManual"
                                            message:@"AVCamManual doesn't have permission to use the Camera"
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                [self setDeviceAuthorized:NO];
            });
        }
    }];
}

#pragma mark - Transplanted Camera Methods
- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
    [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
    [self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
    
    [self addObserver:self forKeyPath:@"videoDeviceInput.device.focusMode" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:FocusModeContext];
    [self addObserver:self forKeyPath:@"videoDeviceInput.device.lensPosition" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:LensPositionContext];
    
    [self addObserver:self forKeyPath:@"videoDeviceInput.device.exposureMode" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:ExposureModeContext];
    [self addObserver:self forKeyPath:@"videoDeviceInput.device.exposureDuration" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:ExposureDurationContext];
    [self addObserver:self forKeyPath:@"videoDeviceInput.device.ISO" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:ISOContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[self videoDevice]];
    
    __weak ViewController *weakSelf = self;
    [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
        ViewController *strongSelf = weakSelf;
        dispatch_async([strongSelf sessionQueue], ^{
            // Manually restart the session since it must have been stopped due to an error
            [[strongSelf session] startRunning];
            // [[strongSelf recordButton] setTitle:NSLocalizedString(@"Record", @"Recording button record title") forState:UIControlStateNormal];
        });
    }]];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[self videoDevice]];
    [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
    
    [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
    [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
    [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
    
    [self removeObserver:self forKeyPath:@"videoDevice.focusMode" context:FocusModeContext];
    [self removeObserver:self forKeyPath:@"videoDevice.lensPosition" context:LensPositionContext];
    
    [self removeObserver:self forKeyPath:@"videoDevice.exposureMode" context:ExposureModeContext];
    [self removeObserver:self forKeyPath:@"videoDevice.exposureDuration" context:ExposureDurationContext];
    [self removeObserver:self forKeyPath:@"videoDevice.ISO" context:ISOContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
#ifdef TARGET_IPHONE_SIMULATOR
    return;
#endif
    
    if (context == FocusModeContext) {
        AVCaptureFocusMode oldMode = [change[NSKeyValueChangeOldKey] intValue];
        AVCaptureFocusMode newMode = [change[NSKeyValueChangeNewKey] intValue];
        NSLog(@"FOCUS MODE: %@ -> %@", [self stringFromFocusMode:oldMode], [self stringFromFocusMode:newMode]);
        // [self updateSliderConfiguration];
    }
    else if (context == LensPositionContext) {
        float newLensPosition = [change[NSKeyValueChangeNewKey] floatValue];
        NSLog(@"LENS POSITION: %@", @(newLensPosition));
        // self.slider.value = newLensPosition;
    }
    else if (context == ExposureModeContext) {
        AVCaptureExposureMode oldMode = [change[NSKeyValueChangeOldKey] intValue];
        AVCaptureExposureMode newMode = [change[NSKeyValueChangeNewKey] intValue];
        NSLog(@"EXPOSURE MODE: %@ -> %@", [self stringFromExposureMode:oldMode], [self stringFromExposureMode:newMode]);
        // [self.exposureControl setHidden:(newMode==AVCaptureExposureModeContinuousAutoExposure||newMode==AVCaptureExposureModeAutoExpose)];
        // [self.isoControl setHidden:(newMode==AVCaptureExposureModeContinuousAutoExposure||newMode==AVCaptureExposureModeAutoExpose)];
        // [self updateSliderConfiguration];
    }
    else if (context == ExposureDurationContext) {
        double newDurationSeconds = CMTimeGetSeconds([change[NSKeyValueChangeNewKey] CMTimeValue]);
        NSLog(@"EXPOSURE DURATION: %@", @(newDurationSeconds));
    }
    else if (context == ISOContext) {
        float newISO = [change[NSKeyValueChangeNewKey] floatValue];
        NSLog(@"ISO: %@", @(newISO));
    }
    else if (context == CapturingStillImageContext) {
        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
        NSLog(@"CAPTURING STILL IMAGE: %@", isCapturingStillImage?@"YES":@"NO");
        /*
        if (isCapturingStillImage) {
            [self runStillImageCaptureAnimation];
        }
        */
    }
    else if (context == RecordingContext) {
        BOOL isRecording = [change[NSKeyValueChangeNewKey] boolValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"RECORDING: %@", isRecording?@"YES":@"NO");
        });
    }
    else if (context == SessionRunningAndDeviceAuthorizedContext) {
        BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"RUNNING/AUTHORIZED: %@", isRunning?@"YES":@"NO");
        });
    }
    else {
        // [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
    CGPoint devicePoint = CGPointMake(.5, .5);
    if ( !self.videoDevice.focusMode == AVCaptureFocusModeLocked ) {
        [self focusWithMode:self.videoDevice.focusMode exposeWithMode:AVCaptureExposureModeCustom atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
    }
}


- (void)setAutoFocusEnabled:(BOOL)afEnabled {
    AVCaptureFocusMode mode = afEnabled?AVCaptureFocusModeContinuousAutoFocus:AVCaptureFocusModeLocked;
    NSError *error = nil;
    
    if ([self.videoDevice lockForConfiguration:&error]) {
        if ([self.videoDevice isFocusModeSupported:mode]) {
            self.videoDevice.focusMode = mode;
        }
        else {
            NSLog(@"Focus mode %@ is not supported. Focus mode is %@.", [self stringFromFocusMode:mode], [self stringFromFocusMode:self.videoDevice.focusMode]);
        }
        [self.videoDevice unlockForConfiguration];
    }
    else {
        NSLog(@"%@", error);
    }
}

- (void)setAutoExposureEnabled:(BOOL)aeEnabled {
    AVCaptureExposureMode mode = aeEnabled?AVCaptureExposureModeContinuousAutoExposure:AVCaptureExposureModeCustom;
    NSError *error = nil;
    
    if ([self.videoDevice lockForConfiguration:&error]) {
        if ([self.videoDevice isExposureModeSupported:mode]) {
            if ( mode == AVCaptureExposureModeCustom ) {
                float tmpExposure = 1.0f/self.shutterLabel.text.floatValue;
                CMTime tmpExposureTime = CMTimeMakeWithSeconds(tmpExposure, 1000*1000*1000);
                float tmpISO = self.isoLabel.text.floatValue;
                [self.videoDevice setExposureModeCustomWithDuration:tmpExposureTime ISO:tmpISO completionHandler:nil];
            } else {
                self.videoDevice.exposureMode = mode;
            }
        }
        else {
            NSLog(@"Exposure mode %@ is not supported. Exposure mode is %@.", [self stringFromExposureMode:mode], [self stringFromExposureMode:self.videoDevice.exposureMode]);
        }
        [self.videoDevice unlockForConfiguration];
    }
    else {
        NSLog(@"%@", error);
    }
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device {
    if ([device hasFlash] && [device isFlashModeSupported:flashMode]) {
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }
        else {
            NSLog(@"%@", error);
        }
    }
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange {
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *device = [self videoDevice];
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode]) {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            /*
             if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
             {
             [device setExposureMode:exposureMode];
             [device setExposurePointOfInterest:point];
             }
             */
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
        else {
            NSLog(@"%@", error);
        }
    });
}

- (NSString *)stringFromFocusMode:(AVCaptureFocusMode) focusMode {
    NSString *string = @"INVALID FOCUS MODE";
    
    if (focusMode == AVCaptureFocusModeLocked) {
        string = @"Locked";
    }
    else if (focusMode == AVCaptureFocusModeAutoFocus) {
        string = @"Auto";
    }
    else if (focusMode == AVCaptureFocusModeContinuousAutoFocus) {
        string = @"ContinuousAuto";
    }
    
    return string;
}

- (NSString *)stringFromExposureMode:(AVCaptureExposureMode) exposureMode {
    NSString *string = @"INVALID EXPOSURE MODE";
    
    if (exposureMode == AVCaptureExposureModeLocked) {
        string = @"Locked";
    }
    else if (exposureMode == AVCaptureExposureModeAutoExpose) {
        string = @"Auto";
    }
    else if (exposureMode == AVCaptureExposureModeContinuousAutoExposure) {
        string = @"ContinuousAuto";
    }
    else if (exposureMode == AVCaptureExposureModeCustom) {
        string = @"Custom";
    }
    
    return string;
}

- (NSString *)stringFromWhiteBalanceMode:(AVCaptureWhiteBalanceMode) whiteBalanceMode {
    NSString *string = @"INVALID WHITE BALANCE MODE";
    
    if (whiteBalanceMode == AVCaptureWhiteBalanceModeLocked) {
        string = @"Locked";
    }
    else if (whiteBalanceMode == AVCaptureWhiteBalanceModeAutoWhiteBalance) {
        string = @"Auto";
    }
    else if (whiteBalanceMode == AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance) {
        string = @"ContinuousAuto";
    }
    
    return string;
}

#pragma mark File Output Delegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    if (error) {
        NSLog(@"%@", error);
    }
    
    [self setLockInterfaceRotation:NO];
    
    // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
    UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
    [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
    
    [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        }
        
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
        
        if (backgroundRecordingID != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
        }
    }];
}


@end
