//
//  MyViewController.m
//  TestAudio2
//
//  Created by George Chen on 3/5/14.
//  Copyright (c) 2014 George Chen. All rights reserved.
//

#import "MyViewController.h"
#import "MyDrawingView.h"

@interface MyViewController ()

@property (weak, nonatomic) IBOutlet UILabel *outStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *outMessageLabel1;
@property (weak, nonatomic) IBOutlet UILabel *outMessageLabel2;

- (IBAction)onRecordButton:(id)sender;
- (IBAction)onStopButton:(id)sender;
- (IBAction)onPlay1Button:(id)sender;
- (IBAction)onPlay2Button:(id)sender;
- (IBAction)onAux1Button:(id)sender;
- (IBAction)onAux2Button:(id)sender;

@property (weak, nonatomic) IBOutlet MyDrawingView *mainViewer;

@property float StartRecordingTime;
@property float EndRecordingTime;

@end

@implementation MyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/sound.caf"]];

    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityHigh], AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16], AVEncoderBitRateKey,
                                    [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:8192.0], AVSampleRateKey,
                                    nil, nil];
    
    NSError *error = nil;
    
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recordSettings error:&error];
    
    [self redisplay];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) redisplay {
    [self.mainViewer setNeedsDisplay];
}

- (IBAction)onRecordButton:(id)sender {
    [audioRecorder record];
    self.outStatusLabel.text = @"Recording...";
    self.StartRecordingTime = [audioRecorder deviceCurrentTime];
    NSLog(@"Recording");
}

- (IBAction)onStopButton:(id)sender {
    [audioRecorder stop];
    // self.outStatusLabel.text = @"Done Recording.";
    self.EndRecordingTime = [audioRecorder deviceCurrentTime];
    
    self.outStatusLabel.text = [NSString stringWithFormat:@"Recording: %.1f sec",self.EndRecordingTime - self.StartRecordingTime];
    self.outMessageLabel1.text = [NSString stringWithFormat:@"file: %@",audioRecorder.url];
    
    NSLog(@"Done Recording");
    
}

- (IBAction)onPlay1Button:(id)sender {
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioRecorder.url error:&error];
    if (audioPlayer == nil) {
        NSLog(@"audioPlayer is nil");
        self.outMessageLabel1.text = @"audioPlayer bad";
    } else {
        audioPlayer.delegate = self;
    }
    
    if (error) {
        NSLog(@"Error: %@",[error localizedDescription]);
        self.outStatusLabel.text = @"Error";
    } else {
        [audioPlayer prepareToPlay];
        [audioPlayer play];
        self.outStatusLabel.text = @"P1 started";
        NSLog(@"playback started");
    }
    
    self.outMessageLabel2.text = [NSString stringWithFormat:@"url: %@",audioRecorder.url];
    
}

- (IBAction)onPlay2Button:(id)sender {
    self.outStatusLabel.text = @"button-2 hit";
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    self.outStatusLabel.text = @"P finished";
    NSLog(@"playback finished");
}

- (IBAction)onAux1Button:(id)sender {
    UInt32 audioInputIsAvailable;
    UInt32 propertySize = sizeof (audioInputIsAvailable);
    
    
    
    AudioSessionGetProperty (
                             
                             kAudioSessionProperty_AudioInputAvailable,
                             
                             &propertySize,
                             
                             &audioInputIsAvailable // A nonzero value on output means that
                             
                             // audio input is available
                             
                             );
    
    self.outMessageLabel1.text = [NSString stringWithFormat:@"audio_is_avail = %d",(unsigned int)audioInputIsAvailable];
    
}

- (IBAction)onAux2Button:(id)sender {
    // get status
    if (audioPlayer.playing) {
        self.outStatusLabel.text = @"still playing";
    } else {
        self.outStatusLabel.text = @"not still playing";
    }
    
}
@end
