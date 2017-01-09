//
//  ViewController.swift
//  WebRTCDemo
//
//  Created by Mohit Kapadia on 09/01/17.
//  Copyright © 2017 Mohit Kapadia. All rights reserved.
//https://tech.appear.in/2015/05/25/Getting-started-with-WebRTC-on-iOS/

import UIKit
import AVFoundation
class ViewController: UIViewController,RTCPeerConnectionDelegate,RTCSessionDescriptionDelegate {
    let rtcFactory = RTCPeerConnectionFactory()
    let mediaConstraints = RTCMediaConstraints(mandatoryConstraints: [RTCPair(key: "OfferToReceiveAudio", value: "true"),RTCPair(key: "OfferToReceiveVideo", value: "true")], optionalConstraints: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func configureChat()
    {
        RTCPeerConnectionFactory.initializeSSL()
        
        //Deinitialize once done with call
//        RTCPeerConnectionFactory.deinitializeSSL()
        
        /*Note: The RTCPeerConnectionFactory object needs to be alive for the entire duration of your WebRTC session, so you should either make it a singleton or make sure it is retained by using a property (thanks to @tomfilk for pointing this out in the comments!). For simplicity I have not done this in the example above.*/
        
        let url = NSURL(string: "https://file.com")
        let iceServer = RTCICEServer(uri:url as URL! , username: "Mohit", password: "123456")
        
        let peerConnection = rtcFactory.peerConnection(withICEServers: [iceServer], constraints: nil, delegate: self)
        
        
        
        // Find the device that is the front facing camera
        /*AVCaptureDevice *device;
        for (AVCaptureDevice *captureDevice in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] ) {
            if (captureDevice.position == AVCaptureDevicePositionFront) {
                device = captureDevice;
                break;
            }
        }
        
        // Create a video track and add it to the media stream
        if (device) {
            RTCVideoSource *videoSource;
            RTCVideoCapturer *capturer = [RTCVideoCapturer capturerWithDeviceName:device.localizedName];
            videoSource = [factory videoSourceWithCapturer:capturer constraints:nil];
            RTCVideoTrack *videoTrack = [factory videoTrackWithID:videoId source:videoSource];
            [localStream addVideoTrack:videoTrack];
        }*/
        
        let localStream = rtcFactory.mediaStream(withLabel: "someUniqueLabel")
        if let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo){
            if let capturer = RTCVideoCapturer(deviceName: captureDevice.localizedName){
                if let videoSource = rtcFactory.videoSource(with: capturer, constraints: nil){
                    if let videoTrack = rtcFactory.videoTrack(withID: "unique_1", source: videoSource){
                        localStream?.addVideoTrack(videoTrack)
                        peerConnection?.add(localStream)
                    }
                }
            }
        }
        
    }
    
    func offerCall(){
//        RTCMediaConstraints *constraints = [RTCMediaConstraints alloc] initWithMandatoryConstraints:
//        @[
//        [[RTCPair alloc] initWithKey:@"OfferToReceiveAudio" value:@"true"],
//        [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo" value:@"true"]
//        ]
//        optionalConstraints: nil];
//        
//        [peerConnection createOfferWithConstraints:constraints];
        
        
        
    }
    
    //Delegate
    
    
    func didCreateSessionDescription(peerConnection:RTCPeerConnection?,sdp:RTCSessionDescription?,error:NSError?)
    {
        if error != nil{
            let remoteDesc = RTCSessionDescription(type: "offer", sdp: sdp?.description)
            peerConnection!.setRemoteDescriptionWith(self, sessionDescription: remoteDesc)
            
        }else
        {
            peerConnection?.setLocalDescriptionWith(self, sessionDescription: sdp)
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection!, didSetSessionDescriptionWithError error: Error!) {
        if (peerConnection.signalingState == RTCSignalingHaveLocalOffer) {
            // Send offer through the signaling channel of our application
        }else if peerConnection.signalingState == RTCSignalingHaveRemoteOffer || peerConnection.signalingState == RTCSignalingHaveRemotePrAnswer {
            // If we have a remote offer we should add it to the peer connection
//            [peerConnection createAnswerWithConstraints:constraints];
            peerConnection.createAnswer(with: self, constraints: mediaConstraints)
        }
    }    

    func peerConnection(_ peerConnection: RTCPeerConnection!, gotICECandidate candidate: RTCICECandidate!) {
        let candidate : RTCICECandidate = RTCICECandidate(mid: "abc", index: 010, sdp: "alfa")
        peerConnection.add(candidate)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection!, addedStream stream: RTCMediaStream!) {
        // Create a new render view with a size of your choice
        let renderView = RTCEAGLVideoView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        let videoTRack = stream.videoTracks.last as! RTCVideoTrack
        videoTRack.add(renderView)
//        [stream.videoTracks.lastObject addRenderer:self.renderView];
        
        // RTCEAGLVideoView is a subclass of UIView, so renderView
        // can be inserted into your view hierarchy where it suits your application.
    }
}

