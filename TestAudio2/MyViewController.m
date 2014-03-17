//
//  MyViewController.m
//  TestAudio2
//
//  Created by George Chen on 3/5/14.
//  Copyright (c) 2014 George Chen. All rights reserved.
//
//
//#import <QuartzCore/QuartzCore.h>
#import "MyViewController.h"
#import "MyDrawingView.h"
#import <AudioToolbox/CAFFile.h>

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

@property (strong, nonatomic) NSTimer *myTimer;
@property float myCurrentTime;
- (void)updateProgress:(NSTimer *)timer;

@end

@implementation MyViewController

struct CAFAudioFormat {
    UInt64  mSampleRateInt;
    UInt32  mFormatID;
    UInt32  mFormatFlags;
    UInt32  mBytesPerPacket;
    UInt32  mFramesPerPacket;
    UInt32  mChannelsPerFrame;
    UInt32  mBitsPerChannel;
};



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


//struct TestFormat {
//    UInt32  val1;
//    UInt32  val2;
//    Float64 fval1;
//    Float64 fval2;
//    UInt32  val3;
//    UInt32  val4;
//};

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    
    
//    NSURL *soundFileURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/sound.caf"]];
    NSURL *soundFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"sound.caf"]];
    
    NSLog(@"soundFileURL is %@",soundFileURL);

//    recordFilePath = (CFStringRef)[NSTemporaryDirectory() stringByAppendingPathComponent: @"recordedFile.caf"];

    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityHigh], AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16], AVEncoderBitRateKey,
                                    [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:8192], AVSampleRateKey,
                                    nil, nil];
    
    NSError *error = nil;
    
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recordSettings error:&error];
    if (error) {
        NSLog(@"Error creating recorder. %@",error);
    }

    [[AVAudioSession sharedInstance] setDelegate:self];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error) {
        NSLog(@"Error setting category. %@",error);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    [self redisplay];
    
    // bunch of stuff
//    struct TestFormat tf;
//    tf.val1 = 100;
//    tf.val2 = 200;
//    tf.val3 = 300;
//    tf.val4 = 400;
//    tf.fval1 = 8192.0f;
//    tf.fval2 = 8192.555f;
//    
//    const void *myptr = &tf;
//    
//    NSData *nd = [[NSData alloc] initWithBytes:myptr length:32];
//    
//    NSLog(@"data: %@",nd);
    

}

- (void)handleRouteChange:(NSNotification *)notification {
    UInt8 reasonValue = [[notification.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey] intValue];
    NSLog(@"Route Change: %d", reasonValue);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) redisplay {
    [self.mainViewer setNeedsDisplay];
}

- (IBAction)onRecordButton:(id)sender {
    [self.audioRecorder record];
    self.outStatusLabel.text = @"Recording...";
    self.StartRecordingTime = [self.audioRecorder deviceCurrentTime];
    NSLog(@"Recording");
}

- (IBAction)onStopButton:(id)sender {
    [self.audioRecorder stop];
    // self.outStatusLabel.text = @"Done Recording.";
    self.EndRecordingTime = [self.audioRecorder deviceCurrentTime];
    
    self.outStatusLabel.text = [NSString stringWithFormat:@"Recording: %.1f sec",self.EndRecordingTime - self.StartRecordingTime];
    self.outMessageLabel1.text = [NSString stringWithFormat:@"file: %@",self.audioRecorder.url];
    
    NSLog(@"Done Recording");
    
}

- (IBAction)onPlay1Button:(id)sender {
    NSError *error;
    
    NSData *myData = [[NSData alloc] initWithContentsOfURL:self.audioRecorder.url options:0 error:&error];
    if (error) {
        NSLog(@"Error while opening file for data: %@",error);
    }
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:myData error:&error];
//    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioRecorder.url error:&error];
    
    
    if (self.audioPlayer == nil) {
        NSLog(@"audioPlayer is nil");
        self.outMessageLabel1.text = @"audioPlayer bad";
    } else {
        self.audioPlayer.delegate = self;
    }
    
    if (error) {
        NSLog(@"Error: %@",[error localizedDescription]);
        self.outStatusLabel.text = @"Error";
    } else {
        
        NSLog(@"playback will be %f seconds long",self.audioPlayer.duration);
        
        
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
        self.outStatusLabel.text = @"P1 started";
        NSLog(@"playback started");
    }
    
    self.outMessageLabel2.text = [NSString stringWithFormat:@"url: %@",self.audioRecorder.url];
    
    NSDictionary *dict = self.audioPlayer.settings;
    NSLog(@"sample rate is: %@", dict[AVSampleRateKey]);
    
    self.myCurrentTime = 0.0;
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
    
}

- (IBAction)onPlay2Button:(id)sender {
    self.outStatusLabel.text = @"button-2 hit";
    
    // playback, but change the frequency
    
    NSError *error;
    NSData *myData = [[NSData alloc] initWithContentsOfURL:self.audioRecorder.url options:0 error:&error];
    
    if (error) {
        NSLog(@"Error in play2 while getting data (%@)",error);
        return;
    }
    
    [self updateCAFFormat:myData];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:myData error:&error];
    
    if (self.audioPlayer == nil) {
        NSLog(@"audioPlayer is nil");
        self.outMessageLabel1.text = @"audioPlayer bad";
    } else {
        self.audioPlayer.delegate = self;
    }
    
    if (error) {
        NSLog(@"Error: %@",[error localizedDescription]);
        self.outStatusLabel.text = @"Error";
    } else {
        
        NSLog(@"playback2 will be %f seconds long",self.audioPlayer.duration);
        
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
        self.outStatusLabel.text = @"P1 started";
        NSLog(@"playback started");
    }
    
    self.outMessageLabel2.text = [NSString stringWithFormat:@"url: %@",self.audioRecorder.url];
    
    NSDictionary *dict = self.audioPlayer.settings;
    NSLog(@"sample rate is: %@", dict[AVSampleRateKey]);
    
    // add a progress bar.
    
    self.myCurrentTime = 0.0;
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
    

}

- (void)updateProgress:(NSTimer *)timer {
    float percentage = self.audioPlayer.currentTime/self.audioPlayer.duration;
    NSLog(@"update progress %f", percentage);
    self.mainViewer.percentComplete = percentage;
    [self redisplay];

    
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    self.outStatusLabel.text = @"P finished";
    NSLog(@"playback finished");
    
    // stop any timer, if running.
    [self.myTimer invalidate];
    self.mainViewer.percentComplete = 0.0f;
    [self redisplay];
}

- (IBAction)onAux1Button:(id)sender {
//    UInt32 audioInputIsAvailable;
//    UInt32 propertySize = sizeof (audioInputIsAvailable);
    
    self.mainViewer.method = 1;

    NSLog(@"output: %@",[[AVAudioSession sharedInstance] outputDataSource]);
    
    
//    AudioSessionGetProperty (
//                             kAudioSessionProperty_AudioInputAvailable,
//                             &propertySize,
//                             &audioInputIsAvailable // A nonzero value on output means that
//                             
//                             // audio input is available
//                             
//                             );
    
//    self.outMessageLabel1.text = [NSString stringWithFormat:@"audio_is_avail = %d",(unsigned int)audioInputIsAvailable];
    [self redisplay];

}



- (IBAction)onAux2Button:(id)sender {
    // get status
//    if (self.audioPlayer.playing) {
//        self.outStatusLabel.text = @"still playing";
//    } else {
//        self.outStatusLabel.text = @"not still playing";
//    }

    self.mainViewer.method = 2;
    
    NSError *error;
    
    // get details about sound file.
    NSData *soundData = [[NSData alloc] initWithContentsOfURL:self.audioRecorder.url options:0 error:&error];
    NSLog(@"url is %@",self.audioRecorder.url);
    
//    NSData *soundData = [[NSData alloc] initWithContentsOfURL:self.audioRecorder.url];
    
    if (error) {
        NSLog(@"Error during soundData retrieval: (%@)",error);
    }
    
    [self decodeCAFFormat:soundData];
    
}

- (void)decodeCAFFormat:(NSData *)soundData {
    
    long sizeOfSoundData = soundData.length;
    long counterOfSize = 0;
    
    NSLog(@"size of soundData is %lu",sizeOfSoundData);
    
    const void *beginptr = [soundData bytes];
    const void *byteptr = beginptr;
    const char *myptr = byteptr;
    const struct CAFFileHeader *caf = byteptr;
    char *strbuffer = (char *) malloc(10);
    char *formatId  = (char *) malloc(10);
    formatId[4] = 0;
//   NSLog(@"%x ",(unsigned int)caf->mFileType);
    
    UInt16 val16a = CFSwapInt16BigToHost(caf->mFileVersion);
    UInt16 val16b = CFSwapInt16BigToHost(caf->mFileFlags);
    
    strncpy(strbuffer, myptr, 4);
    strbuffer[4] = 0;
    NSLog(@"set string to <%s>",strbuffer);
    if (strcmp(strbuffer, "caff") == 0) {
        NSLog(@"string is equal to caff");
    }
    
    NSLog(@"CAFFileHeader: %s : %d, %d", strbuffer, val16a, val16b);
    
    counterOfSize += 8;
    byteptr += 8;
    
    while (counterOfSize < sizeOfSoundData) {

        // start processing each chunk.
        const struct CAFChunkHeader *cnk = byteptr;
        myptr = byteptr;
        SInt64 val64 = CFSwapInt64BigToHost(cnk->mChunkSize);
//        UInt32 val32 = cnk->mChunkType;

        // get the name of the chunk (chunktype)
        strncpy(strbuffer, myptr, 4);
        
        NSLog(@"------------------------");
        NSLog(@"chunk: %s length: %llu", strbuffer, val64);
        NSData *chunk = [[NSData alloc] initWithBytes:byteptr length:(uint)(12+val64)];

        if (strcmp(strbuffer, "desc") == 0) {

            NSLog(@"[[%@]]",chunk);

            NSLog(@"audio description");
            struct CAFAudioFormat *caff = (struct CAFAudioFormat *) (byteptr + 12);
            
            // the sample rate is a float64, but it is in big-endian format
            // CFSwap will reverse the order, but the new value should use those
            // bytes as a reference and not value.
            UInt64 newRate64 = CFSwapInt64BigToHost(caff->mSampleRateInt);
            Float64 *f64 = (Float64 *) (& newRate64);
            
//            Float64 newFloatRate = (Float64) newRate64;
            NSLog(@"sample rate %f",     *f64);
            strncpy(formatId, (const char *) &(caff->mFormatID), 4);
//            char *cptr = &(caff->mFormatID);
            NSLog(@"format id: %s",  formatId);
            NSLog(@"format flags: %d",     CFSwapInt32BigToHost(caff->mFormatFlags));
            NSLog(@"bytes per packet: %d", CFSwapInt32BigToHost(caff->mBytesPerPacket));
            NSLog(@"frames per pak: %d",   CFSwapInt32BigToHost(caff->mFramesPerPacket));
            NSLog(@"channels per fram: %d",CFSwapInt32BigToHost(caff->mChannelsPerFrame));
            NSLog(@"bits per channel: %d", CFSwapInt32BigToHost(caff->mBitsPerChannel));
        } else if (strcmp(strbuffer, "free") == 0) {
            NSLog(@"free block, skipping %llu bytes", val64);
        } else if (strcmp(strbuffer, "data") == 0) {
            // read data here.
        
            if (strcmp(formatId,"lpcm") == 0) {
//                NSData *block = [[NSData alloc] initWithBytes:(byteptr+12) length:200];
//                NSLog(@"lpcm data: %@",block);
                long long number_of_samples = val64/2;
                NSLog(@"%lld samples in chunk", number_of_samples);
                
                NSData *block = [[NSData alloc] initWithBytes:(byteptr+12) length:(unsigned int)val64];
                
                SInt16 *sptr = (SInt16 *)byteptr+12;
                int i;
                int max_val = 0;
                int min_val = 0;
                int cur_val = 0;
                for (i=0; i<number_of_samples; i++) {
                    max_val = MAX(max_val, *sptr);
                    min_val = MIN(min_val, *sptr);
                    cur_val = *sptr++;
//                    if (i<100) {
//                        NSLog(@"view (%d) = %d.  max= %d  min= %d",i,cur_val, max_val, min_val);
//                    }
                    // sptr++;
                }
                NSLog(@"max value is %d, min value is %d", max_val, min_val);
                self.mainViewer.myData = block;
                [self redisplay];

            }
            
            
        } else {
            NSLog(@"what do I do with %s",strbuffer);
        }
    
        // next chunk
        byteptr += 12;
        byteptr += val64;
        counterOfSize += 12 + val64;
    }
    


    
//    chunk = [[NSData alloc] initWithBytes:byteptr length:300];
//    NSLog(@"[[%@]]",chunk);
    
}

//    val = ((val << 8) & 0xFF00FF00FF00FF00ULL ) | ((val >> 8) & 0x00FF00FF00FF00FFULL );
//    val = ((val << 16) & 0xFFFF0000FFFF0000ULL ) | ((val >> 16) & 0x0000FFFF0000FFFFULL );
//    val = (val << 32) | (val >> 32);


- (void)updateCAFFormat:(NSData *)soundData {
    
    // Change the frequency.
    
    long sizeOfSoundData = soundData.length;
    long counterOfSize = 0;
    
    const void *beginptr = [soundData bytes];
    const void *byteptr = beginptr;
    const char *myptr = byteptr;
    const struct CAFFileHeader *caf = byteptr;
    char *strbuffer = (char *) malloc(10);
    char *formatId  = (char *) malloc(10);
    formatId[4] = 0;
    //   NSLog(@"%x ",(unsigned int)caf->mFileType);
    
    UInt16 val16a = CFSwapInt16BigToHost(caf->mFileVersion);
    UInt16 val16b = CFSwapInt16BigToHost(caf->mFileFlags);
    
    strncpy(strbuffer, myptr, 4);
    strbuffer[4] = 0;
    NSLog(@"set string to <%s>",strbuffer);
    if (strcmp(strbuffer, "caff") == 0) {
        NSLog(@"string is equal to caff");
    }
    
    NSLog(@"CAFFileHeader: %s : %d, %d", strbuffer, val16a, val16b);
    
    counterOfSize += 8;
    byteptr += 8;
    
    while (counterOfSize < sizeOfSoundData) {
        
        // start processing each chunk.
        const struct CAFChunkHeader *cnk = byteptr;
        myptr = byteptr;
        SInt64 val64 = CFSwapInt64BigToHost(cnk->mChunkSize);
        //        UInt32 val32 = cnk->mChunkType;
        
        // get the name of the chunk (chunktype)
        strncpy(strbuffer, myptr, 4);
        
        NSLog(@"------------------------");
        NSLog(@"chunk: %s length: %llu", strbuffer, val64);
        NSData *chunk = [[NSData alloc] initWithBytes:byteptr length:(uint)(12+val64)];
        
        if (strcmp(strbuffer, "desc") == 0) {
            
            NSLog(@"[[%@]]",chunk);
            
            NSLog(@"audio description");
            struct CAFAudioFormat *caff = (struct CAFAudioFormat *) (byteptr + 12);
            
            // the sample rate is a float64, but it is in big-endian format
            // CFSwap will reverse the order, but the new value should use those
            // bytes as a reference and not value.
            UInt64 newRate64 = CFSwapInt64BigToHost(caff->mSampleRateInt);
            Float64 *f64 = (Float64 *) (& newRate64);
            
            //            Float64 newFloatRate = (Float64) newRate64;
            NSLog(@"sample rate %f",     *f64);
            
            // change the value.
            Float64 newRate = *f64 * 2.0;
            UInt64 *updatedRate64 = (UInt64 *) (&newRate);
            UInt64 updatedValue = CFSwapInt64HostToBig(*updatedRate64);
            caff->mSampleRateInt = updatedValue;
            
            NSLog(@"Updated sample rate to %f",newRate);
            return;
        }
    }
}


@end
