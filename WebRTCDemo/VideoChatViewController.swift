//
//  VideoChatViewController.swift
//  WebRTCDemo
//
//  Created by Mohit Kapadia on 1/10/17.
//  Copyright © 2017 Mohit Kapadia. All rights reserved.
//

import UIKit

class VideoChatViewController: UIViewController, ARDAppClientDelegate, RTCEAGLVideoViewDelegate {
/*
     @property (strong, nonatomic) ARDAppClient *client;
     @property (strong, nonatomic) IBOutlet RTCEAGLVideoView *remoteView;
     @property (strong, nonatomic) IBOutlet RTCEAGLVideoView *localView;
     @property (strong, nonatomic) RTCVideoTrack *localVideoTrack;
     @property (strong, nonatomic) RTCVideoTrack *remoteVideoTrack;
     */
    @IBOutlet weak var remoteView: RTCEAGLVideoView!
    @IBOutlet weak var localView: RTCEAGLVideoView!
    
    var client : ARDAppClient? = nil
    var localVideoTrack: RTCVideoTrack? = nil
    var remoteVideoTrack: RTCVideoTrack? = nil
    var roomName: String = ""
    
    let hostURLString : String = "https://apprtc.appspot.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureChat()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func configureChat()
    {
        self.client = ARDAppClient(delegate: self)
        /* RTCEAGLVideoViewDelegate provides notifications on video frame dimensions */
        self.remoteView.delegate = self
        self.localView.delegate = self
        self.client?.serverHostUrl = hostURLString
        self.client?.connectToRoom(withId: self.roomName, options: nil)
    }

    //MARK: ----ARDAppClientDelegate-----
    func appClient(_ client: ARDAppClient!, didChange state: ARDAppClientState) {
        switch state {
        case .connected:
            print("connected")
        case .connecting:
            print("connecting")
        case .disconnected:
            print("disconnected")
            
        default:
            print("no state for ardAppClient")
        }
    }
    
    
    func appClient(_ client: ARDAppClient!, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack!) {
        self.localVideoTrack = localVideoTrack
        self.localVideoTrack?.add(self.localView)
    }
    
    func appClient(_ client: ARDAppClient!, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack!) {
        self.remoteVideoTrack = remoteVideoTrack
        self.remoteVideoTrack?.add(self.remoteView)
    }
    
    func appClient(_ client: ARDAppClient!, didError error: Error!) {
       print("Error:\(error) ")
        self.disconnect()
    }
    
    func videoView(_ videoView: RTCEAGLVideoView!, didChangeVideoSize size: CGSize) {
        //video size changed
    }
    
    func disconnect()
    {
        if self.client != nil{
            if self.localVideoTrack != nil{
                self.localVideoTrack?.remove(self.localView)
            }
            
            if self.remoteVideoTrack != nil{
                self.remoteVideoTrack?.remove(self.remoteView)
            }
            
            self.localVideoTrack = nil
            self.remoteVideoTrack = nil
            self.client?.disconnect()            
        }
    }

}
