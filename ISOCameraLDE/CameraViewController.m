//
//  CameraViewController.m
//  ISOCameraLDE
//
//  Created by Xcode Developer on 6/17/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

@import AVFoundation;
@import Photos;

#import "CameraViewController.h"
#import "CameraView.h"
#import "CameraControlsView.h"
#import "CollectionViewCell.h"
#import "ScaleSliderControlView.h"
#import "CameraControlsView.h"

static void * SessionRunningContext = &SessionRunningContext;
static void * LensPositionContext = &LensPositionContext;
static void * ISOContext = &ISOContext;
static void * TorchContext = &TorchContext;

typedef NS_ENUM( NSInteger, AVCamManualSetupResult ) {
    AVCamManualSetupResultSuccess,
    AVCamManualSetupResultCameraNotAuthorized,
    AVCamManualSetupResultSessionConfigurationFailed
};

// TO-DO:
// 1. Adjust white balance when torch is toggled
// 2. Add a key-value observer for changes to torch
// 3. Set to highest camera resolution available

@interface CameraViewController () <AVCaptureFileOutputRecordingDelegate>

@property (weak, nonatomic) IBOutlet CameraView *cameraView;

@property (weak, nonatomic) IBOutlet CameraControlsView *cameraControlsView;

@property (weak, nonatomic) IBOutlet UICollectionView *SliderControlCollectionView;
@property (weak, nonatomic) IBOutlet ScaleSliderControlView *scaleSliderControlView;

// Session management
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureDeviceDiscoverySession *videoDeviceDiscoverySession;

@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;

// Utilities
@property (nonatomic) AVCamManualSetupResult setupResult;
@property (nonatomic, getter=isSessionRunning) BOOL sessionRunning;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;

@end

@implementation CameraViewController
static NSString * const reuseIdentifier = @"CollectionViewCellReuseIdentifier";

@synthesize focus = _focus, ISO = _ISO;

#pragma mark View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.SliderControlCollectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.SliderControlCollectionView setDelegate:(id<UICollectionViewDelegate>)self.cameraControlsView];
    [self.SliderControlCollectionView setDataSource:(id<UICollectionViewDataSource>)self.cameraControlsView];
    
    [self.cameraControlsView setDelegate:(id<CameraControlsDelegate> _Nullable)self];
//    [self.scaleSliderScrollView setDelegate:(id<UIScrollViewDelegate> _Nullable)self.cameraControlsView];
    // Create the AVCaptureSession
    self.session = [[AVCaptureSession alloc] init];
    
    // Create a device discovery session
    NSArray<NSString *> *deviceTypes = @[AVCaptureDeviceTypeBuiltInDualCamera];
    self.videoDeviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:deviceTypes mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
    
    // Set up the preview view
    self.cameraView.session = self.session;
    
    // Communicate with the session and other session objects on this queue
    self.sessionQueue = dispatch_queue_create( "session queue", DISPATCH_QUEUE_SERIAL );
    
    self.setupResult = AVCamManualSetupResultSuccess;
    
    // Check video authorization status. Video access is required and audio access is optional.
    // If audio access is denied, audio is not recorded during movie recording.
    switch ( [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] )
    {
        case AVAuthorizationStatusAuthorized:
        {
            // The user has previously granted access to the camera
            break;
        }
        case AVAuthorizationStatusNotDetermined:
        {
            // The user has not yet been presented with the option to grant video access.
            // We suspend the session queue to delay session running until the access request has completed.
            // Note that audio access will be implicitly requested when we create an AVCaptureDeviceInput for audio during session setup.
            dispatch_suspend( self.sessionQueue );
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^( BOOL granted ) {
                if ( ! granted ) {
                    self.setupResult = AVCamManualSetupResultCameraNotAuthorized;
                }
                dispatch_resume( self.sessionQueue );
            }];
            break;
        }
        default:
        {
            // The user has previously denied access
            self.setupResult = AVCamManualSetupResultCameraNotAuthorized;
            break;
        }
    }
    
    // Setup the capture session.
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // Because -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue
    // so that the main queue isn't blocked, which keeps the UI responsive.
    dispatch_async( self.sessionQueue, ^{
        [self configureSession];
    } );
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    dispatch_async( self.sessionQueue, ^{
        switch ( self.setupResult )
        {
            case AVCamManualSetupResultSuccess:
            {
                // Only setup observers and start the session running if setup succeeded
                //                [self addObservers];
                [self.session startRunning];
                self.sessionRunning = self.session.isRunning;
                break;
            }
            case AVCamManualSetupResultCameraNotAuthorized:
            {
                dispatch_async( dispatch_get_main_queue(), ^{
                    NSString *message = NSLocalizedString( @"AVCamManual doesn't have permission to use the camera, please change privacy settings", @"Alert message when the user has denied access to the camera" );
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"AVCamManual" message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", @"Alert OK button" ) style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    // Provide quick access to Settings
                    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Settings", @"Alert button to open Settings" ) style:UIAlertActionStyleDefault handler:^( UIAlertAction *action ) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                    }];
                    [alertController addAction:settingsAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                } );
                break;
            }
            case AVCamManualSetupResultSessionConfigurationFailed:
            {
                dispatch_async( dispatch_get_main_queue(), ^{
                    NSString *message = NSLocalizedString( @"Unable to capture media", @"Alert message when something goes wrong during capture session configuration" );
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"AVCamManual" message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", @"Alert OK button" ) style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                } );
                break;
            }
        }
    } );
}

- (void)viewDidDisappear:(BOOL)animated
{
    dispatch_async( self.sessionQueue, ^{
        if ( self.setupResult == AVCamManualSetupResultSuccess ) {
            [self.session stopRunning];
            //            [self removeObservers];
        }
    } );
    
    [super viewDidDisappear:animated];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    if ( UIDeviceOrientationIsPortrait( deviceOrientation ) || UIDeviceOrientationIsLandscape( deviceOrientation ) ) {
        AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.cameraView.layer;
        previewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
    }
}

//- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
//    <#code#>
//}
//
//
//- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
//    <#code#>
//}
//
//
//- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
//    <#code#>
//}
//
//
//- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
//    <#code#>
//}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    // Disable autorotation of the interface when recording is in progress
    return FALSE;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark HUD

//- (void)configureManualHUD
//{
//    if (self.videoDevice != nil)
//    {
//        if (([self.videoDevice isFocusModeSupported:AVCaptureFocusModeLocked]       && self.videoDevice.focusMode == AVCaptureFocusModeLocked) &&
//            ([self.videoDevice isExposureModeSupported:AVCaptureExposureModeCustom] && self.videoDevice.exposureMode == AVCaptureExposureModeCustom))
//        {
//            self.ISOSlider.minimumValue = self.videoDevice.activeFormat.minISO;
//            self.ISOSlider.maximumValue = self.videoDevice.activeFormat.maxISO;
//            self.ISOSlider.value = self.videoDevice.ISO;
//            self.ISOSlider.enabled = ( self.videoDevice.exposureMode == AVCaptureExposureModeCustom );
//        }
//    }
//
//
//}

#pragma mark Session Management

// Should be called on the session queue
- (void)configureSession
{
    if ( self.setupResult != AVCamManualSetupResultSuccess ) {
        return;
    }
    
    NSError *error = nil;
    
    [self.session beginConfiguration];
    
    self.session.sessionPreset = AVCaptureSessionPreset3840x2160;
    
    // Add video input
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if ( ! videoDeviceInput ) {
        NSLog( @"Could not create video device input: %@", error );
        self.setupResult = AVCamManualSetupResultSessionConfigurationFailed;
        [self.session commitConfiguration];
        return;
    }
    if ( [self.session canAddInput:videoDeviceInput] ) {
        [self.session addInput:videoDeviceInput];
        self.videoDeviceInput = videoDeviceInput;
        self.videoDevice = videoDevice;
        
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        
        if ( [self.session canAddOutput:movieFileOutput] ) {
            [self.session addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if ( connection.isVideoStabilizationSupported ) {
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            }
            
            self.movieFileOutput = movieFileOutput;
            
            dispatch_async( dispatch_get_main_queue(), ^{
                //                //[self.recordButton setImage:[[UIImage systemImageNamed:@"stop.circle"] imageWithTintColor:[UIColor redColor]] forState:UIControlStateNormal];
                //                //[self.recordButton setTintColor:[UIColor redColor]];
            } );
        }
        
        dispatch_async( dispatch_get_main_queue(), ^{
            /*
             Why are we dispatching this to the main queue?
             Because AVCaptureVideoPreviewLayer is the backing layer for AVCamManualPreviewView and UIView
             can only be manipulated on the main thread.
             Note: As an exception to the above rule, it is not necessary to serialize video orientation changes
             on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
             
             Use the status bar orientation as the initial video orientation. Subsequent orientation changes are
             handled by -[AVCamManualCameraViewController viewWillTransitionToSize:withTransitionCoordinator:].
             */
            UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
            AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
            if ( statusBarOrientation != UIInterfaceOrientationUnknown ) {
                initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
            }
            
            AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.cameraView.layer;
            previewLayer.connection.videoOrientation = initialVideoOrientation;
        } );
    }
    else {
        NSLog( @"Could not add video device input to the session" );
        self.setupResult = AVCamManualSetupResultSessionConfigurationFailed;
        [self.session commitConfiguration];
        return;
    }
    
    // Add audio input
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    if ( ! audioDeviceInput ) {
        NSLog( @"Could not create audio device input: %@", error );
    }
    if ( [self.session canAddInput:audioDeviceInput] ) {
        [self.session addInput:audioDeviceInput];
    }
    else {
        NSLog( @"Could not add audio device input to the session" );
    }
    
    // We will not create an AVCaptureMovieFileOutput when configuring the session because the AVCaptureMovieFileOutput does not support movie recording with AVCaptureSessionPresetPhoto
    self.backgroundRecordingID = UIBackgroundTaskInvalid;
    
    [self.session commitConfiguration];
    
    dispatch_async( self.sessionQueue, ^{
        AVCaptureDevice *device = self.videoDevice;
        
        __autoreleasing NSError *error = nil;
        if ( [device lockForConfiguration:&error] ) {
            if ( [self.videoDevice isFocusModeSupported:AVCaptureFocusModeLocked] ) {
                self.videoDevice.focusMode = AVCaptureFocusModeLocked;
                self.videoDevice.smoothAutoFocusEnabled = FALSE;
            }
            else {
                NSLog( @"Focus mode AVCaptureFocusModeLocked is not supported.");
            }
            
            if ( [self.videoDevice isExposureModeSupported:AVCaptureExposureModeCustom] ) {
                self.videoDevice.exposureMode = AVCaptureExposureModeCustom;
                [self.videoDevice setExposureModeCustomWithDuration:CMTimeMakeWithSeconds((1.0/3.0), 1000*1000*1000) ISO:self.videoDevice.activeFormat.minISO completionHandler:nil];
                [self.videoDevice unlockForConfiguration];
            }
            else {
                NSLog( @"Exposure mode AVCaptureExposureModeCustom is not supported.");
            }
            
            
            [device unlockForConfiguration];
        }
        else {
            NSLog( @"Could not lock device for configuration: %@", error );
        }
    } );
    
    dispatch_async( dispatch_get_main_queue(), ^{
        //        [self configureManualHUD];
        
    } );
}

- (IBAction)resumeInterruptedSession:(id)sender
{
    dispatch_async( self.sessionQueue, ^{
        // The session might fail to start running, e.g. if a phone or FaceTime call is still using audio or video.
        // A failure to start the session will be communicated via a session runtime error notification.
        // To avoid repeatedly failing to start the session running, we only try to restart the session in the
        // session runtime error handler if we aren't trying to resume the session running.
        [self.session startRunning];
        self.sessionRunning = self.session.isRunning;
        if ( ! self.session.isRunning ) {
            dispatch_async( dispatch_get_main_queue(), ^{
                NSString *message = NSLocalizedString( @"Unable to resume", @"Alert message when unable to resume the session running" );
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"AVCamManual" message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", @"Alert OK button" ) style:UIAlertActionStyleCancel handler:nil];
                [alertController addAction:cancelAction];
                [self presentViewController:alertController animated:YES completion:nil];
            } );
        }
        else {
            dispatch_async( dispatch_get_main_queue(), ^{
                //                self.resumeButton.hidden = YES;
            } );
        }
    } );
}

#pragma mark Device Configuration

- (IBAction)testAction:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (IBAction)changeLensPosition:(id)sender
{
    UISlider *control = sender;
    NSError *error = nil;
    
    if ( [self.videoDevice lockForConfiguration:&error] ) {
        [self.videoDevice setFocusModeLockedWithLensPosition:control.value completionHandler:nil];
        [self.videoDevice unlockForConfiguration];
    }
    else {
        NSLog( @"Could not lock device for configuration: %@", error );
    }
}

//- (void)changeISO:(id)sender
//{
//    __autoreleasing NSError *error = nil;
//
//    if ( [self.videoDevice lockForConfiguration:&error] ) {
//        @try {
//            [self.videoDevice setExposureModeCustomWithDuration:CMTimeMakeWithSeconds( (1.0/3.0), 1000*1000*1000 ) ISO:([self.torchButton isSelected]) ? self.videoDevice.activeFormat.maxISO : self.videoDevice.activeFormat.minISO completionHandler:nil];
//        } @catch (NSException *exception) {
//            NSLog( @"Exposure mode AVCaptureExposureModeCustom is not supported.");
//        } @finally {
//
//        }
//
//        [self.videoDevice unlockForConfiguration];
//    }
//    else {
//        NSLog( @"Could not lock device for configuration: %@", error );
//    }
//}

//- (void)normalizeExposureDuration:(BOOL)shouldNormalizeExposureDuration
//{
//    __autoreleasing NSError *error = nil;
//    if ( [self.videoDevice lockForConfiguration:&error] ) {
//        @try {
//            if (shouldNormalizeExposureDuration)
//                [self.videoDevice setExposureModeCustomWithDuration:kCMTimeInvalid /*CMTimeMakeWithSeconds( (1.0/3.0), 1000*1000*1000 )*/ ISO:self.videoDevice.activeFormat.maxISO completionHandler:nil];
//            else
//                [self.videoDevice setExposureModeCustomWithDuration:CMTimeMakeWithSeconds( (1.0/3.0), 1000*1000*1000 ) ISO:(self.ISO < self.videoDevice.activeFormat.minISO) ? self.videoDevice.activeFormat.minISO : self.ISO completionHandler:nil];
//        } @catch (NSException *exception) {
//            NSLog( @"Error setting exposure mode to AVCaptureExposureModeCustom:\t%@\n%@.", error.description, exception.description);
//        } @finally {
//
//        }
//
//        [self.videoDevice unlockForConfiguration];
//    }
//    else {
//        NSLog( @"Could not lock device for configuration: %@", error );
//    }
//}

#pragma mark Recording Movies

- (void)toggleRecordingWithCompletionHandler:(void (^)(BOOL isRunning, NSError *error))completionHandler
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // Retrieve the video preview layer's video orientation on the main queue before entering the session queue. We do this to ensure UI
    // elements are accessed on the main thread and session configuration is done on the session queue.
    AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.cameraView.layer;
    AVCaptureVideoOrientation previewLayerVideoOrientation = previewLayer.connection.videoOrientation;
    dispatch_async( self.sessionQueue, ^{
        if ( ! self.movieFileOutput.isRecording ) {
            dispatch_async( dispatch_get_main_queue(), ^{
                //[self.recordButton setImage:[[UIImage systemImageNamed:@"stop.circle"] imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
                //[self.recordButton setTintColor:[UIColor whiteColor]];
            });
            if ( [UIDevice currentDevice].isMultitaskingSupported ) {
                // Setup background task. This is needed because the -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:]
                // callback is not received until AVCamManual returns to the foreground unless you request background execution time.
                // This also ensures that there will be time to write the file to the photo library when AVCamManual is backgrounded.
                // To conclude this background execution, -endBackgroundTask is called in
                // -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:] after the recorded file has been saved.
                self.backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
            }
            AVCaptureConnection *movieConnection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            movieConnection.videoOrientation = previewLayerVideoOrientation;
            
            // Start recording to temporary file
            NSString *outputFileName = [NSProcessInfo processInfo].globallyUniqueString;
            NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:@"mov"]];
            [self.movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
            completionHandler(TRUE, nil);
        }
        else {
            [self.movieFileOutput stopRecording];
            dispatch_async( dispatch_get_main_queue(), ^{
                //[self.recordButton setImage:[[UIImage systemImageNamed:@"stop.circle"] imageWithTintColor:[UIColor redColor]] forState:UIControlStateNormal];
                //[self.recordButton setTintColor:[UIColor redColor]];
            });
            completionHandler(FALSE, nil);
        }
    } );
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // Enable the Record button to let the user stop the recording
    dispatch_async( dispatch_get_main_queue(), ^{
        //[self.recordButton setImage:[[UIImage systemImageNamed:@"stop.circle.fill"] imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        //[self.recordButton setTintColor:[UIColor whiteColor]];
    });
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    // Note that currentBackgroundRecordingID is used to end the background task associated with this recording.
    // This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's isRecording property
    // is back to NO — which happens sometime after this method returns.
    // Note: Since we use a unique file path for each recording, a new recording will not overwrite a recording currently being saved.
    UIBackgroundTaskIdentifier currentBackgroundRecordingID = self.backgroundRecordingID;
    self.backgroundRecordingID = UIBackgroundTaskInvalid;
    
    dispatch_block_t cleanup = ^{
        if ( [[NSFileManager defaultManager] fileExistsAtPath:outputFileURL.path] ) {
            [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
        }
        
        if ( currentBackgroundRecordingID != UIBackgroundTaskInvalid ) {
            [[UIApplication sharedApplication] endBackgroundTask:currentBackgroundRecordingID];
        }
    };
    
    BOOL success = YES;
    
    if ( error ) {
        NSLog( @"Error occurred while capturing movie: %@", error );
        success = [error.userInfo[AVErrorRecordingSuccessfullyFinishedKey] boolValue];
    }
    if ( success ) {
        // Check authorization status
        [PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status ) {
            if ( status == PHAuthorizationStatusAuthorized ) {
                // Save the movie file to the photo library and cleanup
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    // In iOS 9 and later, it's possible to move the file into the photo library without duplicating the file data.
                    // This avoids using double the disk space during save, which can make a difference on devices with limited free disk space.
                    PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
                    options.shouldMoveFile = YES;
                    PHAssetCreationRequest *changeRequest = [PHAssetCreationRequest creationRequestForAsset];
                    [changeRequest addResourceWithType:PHAssetResourceTypeVideo fileURL:outputFileURL options:options];
                } completionHandler:^( BOOL success, NSError *error ) {
                    if ( ! success ) {
                        NSLog( @"Could not save movie to photo library: %@", error );
                    }
                    cleanup();
                }];
            }
            else {
                cleanup();
            }
        }];
    }
    else {
        cleanup();
    }
}

#pragma mark KVO and Notifications

//- (void)addObservers
//{
//    [self addObserver:self forKeyPath:@"session.running" options:NSKeyValueObservingOptionNew context:SessionRunningContext];
//    [self addObserver:self forKeyPath:@"videoDevice.lensPosition" options:NSKeyValueObservingOptionNew context:LensPositionContext];
//    [self addObserver:self forKeyPath:@"videoDevice.ISO" options:NSKeyValueObservingOptionNew context:ISOContext];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:self.session];
//    // A session can only run when the app is full screen. It will be interrupted in a multi-app layout, introduced in iOS 9,
//    // see also the documentation of AVCaptureSessionInterruptionReason. Add observers to handle these session interruptions
//    // and show a preview is paused message. See the documentation of AVCaptureSessionWasInterruptedNotification for other
//    // interruption reasons.
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionWasInterrupted:) name:AVCaptureSessionWasInterruptedNotification object:self.session];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInterruptionEnded:) name:AVCaptureSessionInterruptionEndedNotification object:self.session];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleTorch:) name:NSProcessInfoThermalStateDidChangeNotification object:nil];
//}
//
//- (void)removeObservers
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//
//    [self removeObserver:self forKeyPath:@"session.running" context:SessionRunningContext];
//    [self removeObserver:self forKeyPath:@"videoDevice.lensPosition" context:LensPositionContext];
//    [self removeObserver:self forKeyPath:@"videoDevice.ISO" context:ISOContext];
//}

// TO-DO: Add AVCaptureSession notificatioms related to running and modify record/stop button

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    id newValue = change[NSKeyValueChangeNewKey];
//    
//    if ( context == LensPositionContext ) {
//        if ( newValue && newValue != [NSNull null] ) {
//            AVCaptureFocusMode focusMode = self.videoDevice.focusMode;
//            float newLensPosition = [newValue floatValue];
//            dispatch_async( dispatch_get_main_queue(), ^{
//                if ( focusMode != AVCaptureFocusModeLocked ) {
//                    self.lensPositionSlider.value = newLensPosition;
//                }
//                self.lensPositionValueLabel.text = [NSString stringWithFormat:@"%.1f", newLensPosition];
//            } );
//        }
//    }
//    else if ( context == ISOContext ) {
//        if ( newValue && newValue != [NSNull null] ) {
//            float newISO = [newValue floatValue];
//            AVCaptureExposureMode exposureMode = self.videoDevice.exposureMode;
//            
//            dispatch_async( dispatch_get_main_queue(), ^{
//                if ( exposureMode != AVCaptureExposureModeCustom ) {
//                    self.ISOSlider.value = newISO;
//                }
//                self.ISOValueLabel.text = [NSString stringWithFormat:@"%i", (int)newISO];
//            } );
//        }
//    }
//    else if ( context == SessionRunningContext ) {
//        BOOL isRunning = NO;
//        if ( newValue && newValue != [NSNull null] ) {
//            isRunning = [newValue boolValue];
//        }
//        dispatch_async( dispatch_get_main_queue(), ^{
//            dispatch_async( dispatch_get_main_queue(), ^{
//                //[self.recordButton setImage:[[UIImage systemImageNamed:@"stop.circle"] imageWithTintColor:[UIColor redColor]] forState:UIControlStateNormal];
//                //[self.recordButton setTintColor:[UIColor redColor]];
//            });
//        } );
//    }
//    else {
//        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
//    }
//}

- (void)sessionRuntimeError:(NSNotification *)notification
{
    NSError *error = notification.userInfo[AVCaptureSessionErrorKey];
    NSLog( @"Capture session runtime error: %@", error );
    
    if ( error.code == AVErrorMediaServicesWereReset ) {
        dispatch_async( self.sessionQueue, ^{
            // If we aren't trying to resume the session, try to restart it, since it must have been stopped due to an error (see -[resumeInterruptedSession:])
            if ( self.isSessionRunning ) {
                [self.session startRunning];
                self.sessionRunning = self.session.isRunning;
            }
            else {
                dispatch_async( dispatch_get_main_queue(), ^{
                    //                    self.resumeButton.hidden = NO;
                } );
            }
        } );
    }
    else {
        //        self.resumeButton.hidden = NO;
    }
}

- (void)sessionWasInterrupted:(NSNotification *)notification
{
    // In some scenarios we want to enable the user to restart the capture session.
    // For example, if music playback is initiated via Control Center while using AVCamManual,
    // then the user can let AVCamManual resume the session running, which will stop music playback.
    // Note that stopping music playback in Control Center will not automatically resume the session.
    // Also note that it is not always possible to resume, see -[resumeInterruptedSession:].
    // In iOS 9 and later, the notification's userInfo dictionary contains information about why the session was interrupted
    AVCaptureSessionInterruptionReason reason = [notification.userInfo[AVCaptureSessionInterruptionReasonKey] integerValue];
    NSLog( @"Capture session was interrupted with reason %ld", (long)reason );
    
    if ( reason == AVCaptureSessionInterruptionReasonAudioDeviceInUseByAnotherClient ||
        reason == AVCaptureSessionInterruptionReasonVideoDeviceInUseByAnotherClient ) {
        // Simply fade-in a button to enable the user to try to resume the session running
        //        self.resumeButton.hidden = NO;
        //        self.resumeButton.alpha = 0.0;
        //        [UIView animateWithDuration:0.25 animations:^{
        //            self.resumeButton.alpha = 1.0;
        //        }];
    }
    else if ( reason == AVCaptureSessionInterruptionReasonVideoDeviceNotAvailableWithMultipleForegroundApps ) {
        // Simply fade-in a label to inform the user that the camera is unavailable
        //        self.cameraUnavailableLabel.hidden = NO;
        //        self.cameraUnavailableLabel.alpha = 0.0;
        //        [UIView animateWithDuration:0.25 animations:^{
        //            self.cameraUnavailableLabel.alpha = 1.0;
        //        }];
    }
}

- (void)sessionInterruptionEnded:(NSNotification *)notification
{
    NSLog( @"Capture session interruption ended" );
    
    //    if ( ! self.resumeButton.hidden ) {
    //        [UIView animateWithDuration:0.25 animations:^{
    //            self.resumeButton.alpha = 0.0;
    //        } completion:^( BOOL finished ) {
    //            self.resumeButton.hidden = YES;
    //        }];
    //    }
    //    if ( ! self.cameraUnavailableLabel.hidden ) {
    //        [UIView animateWithDuration:0.25 animations:^{
    //            self.cameraUnavailableLabel.alpha = 0.0;
    //        } completion:^( BOOL finished ) {
    //            self.cameraUnavailableLabel.hidden = YES;
    //        }];
    //    }
}

- (void)targetExposureDuration:(CMTime)exposureDuration withCompletionHandler:(void (^)(CMTime currentExposureDuration))completionHandler
{
    __autoreleasing NSError *error = nil;
    if (![self.videoDevice isAdjustingExposure] && [self.videoDevice lockForConfiguration:&error]) {
        @try {
            [self.videoDevice setExposureModeCustomWithDuration:exposureDuration ISO:[self.videoDevice ISO] completionHandler:^(CMTime syncTime) {
                completionHandler([self.videoDevice exposureDuration]);
            }];
        } @catch (NSException *exception) {
            NSLog( @"Error setting exposure mode to AVCaptureExposureModeCustom:\t%@\n%@.", error.description, exception.description);
        } @finally {
            [self.videoDevice unlockForConfiguration];
        }
    }
    else {
        NSLog( @"Could not lock device for configuration: %@", error );
    }
}

- (void)setFocus:(float)focus {
    __autoreleasing NSError *error;
     @try {
    if (![self.videoDevice isAdjustingFocus] && [self.videoDevice lockForConfiguration:&error]) {
       
            [self.videoDevice setFocusModeLockedWithLensPosition:focus completionHandler:nil];
        } else {
            if (![self.videoDevice isAdjustingFocus] && error)
            NSLog( @"Could not lock device to set focus: %@", error.description );
        }
        } @catch (NSException *exception) {
            NSLog( @"ERROR setting focus:\t%@", exception.description);
        } @finally {
            [self.videoDevice unlockForConfiguration];
        }
    
}

- (void)autoFocusWithCompletionHandler:(void (^)(double focus))completionHandler
{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (![self.videoDevice isAdjustingFocus] && [self.videoDevice lockForConfiguration:nil]) {
        @try {
            [self.videoDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        } @catch (NSException *exception) {
            NSLog( @"ERROR auto-focusing:\t%@", exception.description);
        } @finally {
            [self.videoDevice unlockForConfiguration];
            while ([self.videoDevice isAdjustingFocus]) {
                
            }
            completionHandler([self.videoDevice lensPosition]);
        }
    } else {
        NSLog( @"Could not lock device for focus configuration: %@", nil );
    }
}


- (void)autoExposureWithCompletionHandler:(void (^)(double ISO))completionHandler
{
    if (![self.videoDevice isAdjustingExposure] && [self.videoDevice lockForConfiguration:nil]) {
        @try {
            [self.videoDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        } @catch (NSException *exception) {
            NSLog( @"ERROR auto-focusing:\t%@", exception.description);
        } @finally {
            [self.videoDevice unlockForConfiguration];
            while ([self.videoDevice isAdjustingExposure]) {
                
            }
            completionHandler([self.videoDevice ISO]);
        }
    } else {
        NSLog( @"Could not lock device for focus configuration: %@", nil );
    }
}

- (void)setISO:(float)ISO {
    if ( [self.videoDevice lockForConfiguration:nil] && ![self.videoDevice isAdjustingExposure]) {
        @try {
            float maxISO = self.videoDevice.activeFormat.maxISO;
            float minISO = self.videoDevice.activeFormat.minISO;
            self->_ISO = minISO + (ISO * (maxISO - minISO));
            [self.videoDevice setExposureModeCustomWithDuration:[self.videoDevice exposureDuration] ISO:self->_ISO completionHandler:nil];
        } @catch (NSException *exception) {
            NSLog( @"ERROR setting ISO (%f): %@\t%f\t%f", self->_ISO, exception.description, self.videoDevice.activeFormat.minISO, self.videoDevice.activeFormat.maxISO);
        } @finally {
            [self.videoDevice unlockForConfiguration];
        }
    }
    else {
        NSLog( @"Could not lock device for configuration: %@", nil );
    }
}

- (void)toggleTorchWithCompletionHandler:(void (^)(BOOL isTorchActive))completionHandler;
{
    __autoreleasing NSError *error;
    BOOL isTorchActive = self.videoDevice.isTorchActive;
        if ([self->_videoDevice lockForConfiguration:&error]) {
            @try {
                [self->_videoDevice setTorchMode:!isTorchActive];
                completionHandler(!isTorchActive);
            } @catch (NSException *exception) {
                NSLog(@"Error setting torch level/mode:\t%@", exception.description);
            } @finally {
                [self->_videoDevice unlockForConfiguration];
            }
        } else {
            NSLog(@"AVCaptureDevice lockForConfiguration returned error\t%@", error);
        }
}

- (void)setTorchLevel:(float)torchLevel
{
    NSProcessInfoThermalState thermalState = [[NSProcessInfo processInfo] thermalState];
    dispatch_async(dispatch_get_main_queue(), ^{
        __autoreleasing NSError *error;
        if ([self->_videoDevice lockForConfiguration:&error]) {
            if ([self->_videoDevice isTorchActive] && (thermalState != NSProcessInfoThermalStateCritical && thermalState != NSProcessInfoThermalStateSerious))
            {
                [self->_videoDevice setTorchModeOnWithLevel:torchLevel error:nil];
                
            }
        } else {
            NSLog(@"AVCaptureDevice lockForConfiguration returned error\t%@", error);
        }
        [self->_videoDevice unlockForConfiguration];
    });
}

- (void)scrollSliderControlToItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Scrolling to item %lu", indexPath.item);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.SliderControlCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:TRUE]; // scrollRectToVisible:CGRectMake(scrollRect.size.width * location, scrollRect.origin.y, 150.0, scrollRect.size.height) animated:TRUE];
    });
}

//
//
//
//
//- (void)encodeWithCoder:(nonnull NSCoder *)coder {
//    <#code#>
//}
//
//- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
//    <#code#>
//}
//
//- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
//    <#code#>
//}
//
//- (void)setNeedsFocusUpdate {
//    <#code#>
//}
//
//- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
//    <#code#>
//}
//
//- (void)updateFocusIfNeeded {
//    <#code#>
//}

@end
