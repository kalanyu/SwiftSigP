//
//  ViewController.swift
//  SMKTunes
//
//  Created by Kalanyu Zintus-art on 10/21/15.
//  Copyright © 2015 KoikeLab. All rights reserved.
//

import Cocoa
import CocoaAsyncSocket

@IBDesignable class ViewController: NSViewController, RoundProgressProtocol, NIDAQreaderProtocol, GCDAsyncSocketDelegate {

    @IBOutlet weak var graphView1: SRMergePlotView! {
        didSet {
            graphView1.title = "Filtered"
            graphView1.totalSecondsToDisplay = 10.0
            graphView1.maxDataRange = 15000
        }
    }
    @IBOutlet weak var graphView2: SRPlotView! {
        didSet {
            graphView2.title = "Split"
            graphView2.totalSecondsToDisplay = 10.0
            graphView2.yTicks[0] = "C1"
            graphView2.yTicks[1] = "C2"
            graphView2.yTicks[2] = "y"
            graphView2.yTicks[3] = "z"
            graphView2.axeLayer?.maxDataRange = 1
            
            //            graphView2.maxDataRange = 15000
        }
    }
    @IBOutlet weak var graphView3: SRMergePlotView! {
        didSet {
            graphView3.title = "Raw"
            graphView3.totalSecondsToDisplay = 10.0
            graphView3.maxDataRange = 15000
        }
    }
    @IBOutlet weak var backgroundView: NSSpashBGView! {
        didSet {
            backgroundView.splashFill(toColor: NSColor(red: 241/255.0, green: 206/255.0, blue: 51/255.0, alpha: 1), .Left)
        }
    }
    @IBOutlet weak var volumeView: CountView! {
        didSet {
            volumeView.title = "Volume"
            volumeView.countText = "100"
        }
    }
    @IBOutlet weak var baseAlignButton: RoundProgressView! {
        didSet {
            baseAlignButton.roundDelegate = self
            baseAlignButton.title = "Align"
        }
    }
    @IBOutlet weak var filterButton: RoundProgressView! {
        didSet {
            filterButton.roundDelegate = self
            filterButton.title = "Filter"
        }
    }
    @IBOutlet weak var normalizeButton: RoundProgressView! {
        didSet {
            normalizeButton.roundDelegate = self
            normalizeButton.title = "Norm"
        }
    }

    @IBOutlet weak var serverButton: NSButton! {
        didSet {
            serverButton.enabled = false
        }
    }
    @IBOutlet weak var rectifyButton: NSButton! {
        didSet {
            rectifyButton.enabled = false
            rectifyButton.title = "Rectify"
        }
    }
    
    @IBOutlet weak var artworkView: NSImageView!
    
    @IBOutlet weak var currentTrackLabel: NSTextField!
    @IBOutlet weak var currentStatusLabel: NSTextField!
    @IBOutlet weak var currentVolumeLabel: NSTextField!
    @IBOutlet weak var artistField: NSTextField!
    @IBOutlet weak var commandField: NSTextField!
    
    private var anotherDataTimer: NSTimer?
    var count = 0
    
    private var dataReader : NIDAQreader?
    private let loadingView = NSSpashBGView(frame: CGRectZero)
    private var loadingLabel = NSTextLabel(frame: CGRectZero)
    private var loadingText = "Status : Waiting for connection" {
        didSet {
            loadingLabel.stringValue = self.loadingText
            loadingLabel.sizeToFit()
        }
    }
    private let progressIndicator = NSProgressIndicator(frame: CGRectZero)
    private var fakeLoadTimer: NSTimer?
    private var listenSocket : GCDAsyncSocket?
    private var socketQueue : dispatch_queue_t?
    private var connectedSockets : Array<GCDAsyncSocket>?
    private var writeOK = false
    private var numberOfChannels = 2;
    private var samplingRate = 1000;

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //prepare loading screen
//        loadingView.frame = self.view.frame
//        progressIndicator.frame = CGRect(center: CGPoint(x: 50, y: 50), size: CGSize(width: 100, height: 100))
//        progressIndicator.style = .SpinningStyle
//        loadingLabel.frame = CGRect(origin: CGPoint(x: progressIndicator.frame.origin.x + progressIndicator.frame.width, y: 0), size: CGSize(width: 100, height: 100))
//        loadingLabel.stringValue = loadingText
//        loadingLabel.font = NSFont.boldSystemFontOfSize(15)
//        loadingLabel.sizeToFit()
//        loadingLabel.frame.origin.y = progressIndicator.frame.origin.y + (progressIndicator.frame.width/2) - (loadingLabel.frame.height/2)
//        loadingLabel.lineBreakMode = .ByTruncatingTail
//        
//        
//        loadingView.addSubview(loadingLabel)
//        loadingView.addSubview(progressIndicator)
//        progressIndicator.startAnimation(nil)
//        loadingView.wantsLayer = true
//        loadingView.layer?.backgroundColor = NSColor.whiteColor().CGColor
//        
//        loadingView.autoresizingMask = [.ViewHeightSizable, .ViewWidthSizable]
//        self.view.addSubview(loadingView)

        
//        anotherDataTimer = NSTimer(timeInterval:1/60, target: self, selector: "addData2", userInfo: nil, repeats: true)
//        NSRunLoop.currentRunLoop().addTimer(anotherDataTimer!, forMode: NSRunLoopCommonModes)
//
//        iController.delegate = self
//        currentTrackLabel.stringValue = "Track: ".stringByAppendingString(iController.currentTrackName())
//        volumeView.countText = String(format: "%2d", iController.currentVolume())
//        artworkView.image = iController.currentTrackAlbumArt()
//        currentStatusLabel.stringValue = "Status: ".stringByAppendingString(iController.currentStatus())
//        artistField.stringValue = "Artist: \(iController.currentArtist())"
//        commandField.stringValue = "Waiting"
//        // Do any additional setup after loading the view.
//        
//        motionSensor.delegate = self
//        motionSensor.scanForRemoteSensor()
        graphView1.maxDataRange = 1
        graphView1.totalChannelsToDisplay = 2
        
        graphView2.totalChannelsToDisplay = 2
        
        graphView3.maxDataRange = 1
        graphView3.totalChannelsToDisplay = 2
        
//        motionClassifier.delegate = self
//        fakeLoadTimer = NSTimer(timeInterval: 3, target: self, selector: "systemStartup", userInfo: nil, repeats: false)
//        NSRunLoop.currentRunLoop().addTimer(fakeLoadTimer!, forMode: NSRunLoopCommonModes)

    }
    
    override func viewWillDisappear() {
        
    }
    
    func systemStartup() {
        loadingView.fade(toAlpha: 0)
    }

    
    func addData2() {
        
        let cgCount = sin(Double(count++) * 1/60) * 15000
        //            let cgCount = 0.0
        graphView1.addData([cgCount+1000, cgCount+2000, cgCount+3000, cgCount+400, cgCount+500 , cgCount+600])
        graphView2.addData([cgCount+1000, cgCount+2000, cgCount+3000, cgCount+400, cgCount+500 , cgCount+600])
        graphView3.addData([cgCount+1000, cgCount+2000, cgCount+3000, cgCount+400, cgCount+500 , cgCount+600])

    }
    
    
    @IBAction func Rectify(sender: NSButton) {
        guard let reader = dataReader else { return }
        
        if (!reader.rectify) {
            sender.title = "Rectified"
        } else {
            sender.title = "Rectify"
        }
            
        reader.rectify = !reader.rectify;
    }
    
    func roundProgressClicked(sender: NSView) {
        if (sender === baseAlignButton) {
            dataReader?.activateZscoreWithBufferSize(Int32(samplingRate) * 2);
            (sender as! RoundProgressView).loadProgressForSeconds(2)
        } else if(sender === normalizeButton) {
            serverButton.enabled = !serverButton.enabled
            dataReader?.activateNormalizationWithBufferSize(Int32(samplingRate) * 5);
            (sender as! RoundProgressView).loadProgressForSeconds(5)

        } else if(sender === filterButton) {
            dataReader?.activateKoikefilterWithBuffersize(Int32(samplingRate));
            (sender as! RoundProgressView).loadProgressForSeconds(1)

        }
    }
    
    
    @IBAction func ReadFromDAQ(sender: NSButton) {
        if (sender.state == NSOnState) {
            sender.title = "Stop"
            //slider from 1 to 6 channels
            //        self.dataReader = [[[NIDAQreader alloc] initWithNumberOfChannels:[channelSlider intValue] andSamplingRate:[dataRateSlider intValue]] autorelease];
            dataReader = NIDAQreader(numberOfChannels: Int32(numberOfChannels), andSamplingRate: Int32(samplingRate));

            dataReader!.delegate = self;
            
            //        NSLog(@"%d channel %d sample rate",[channelSlider intValue], [dataRateSlider intValue]);

            //TODO: add delegate to announce error
            //specify sampling rate as an argument
            let operationQueue = NSOperationQueue()
            operationQueue.addOperationWithBlock({
                self.dataReader?.startCollection()
            })
            
            rectifyButton.enabled = true
        }
        else {
            self.dataReader?.stop()
            serverButton.enabled = false
            rectifyButton.enabled = false
            sender.title = "Read"
        }
    }

    func incomingStream(data: NSMutableArray!) {
        let channel1 = (data.objectAtIndex(0).lastObject as! NSDictionary)["y"]!.doubleValue
        let channel2 = (data.objectAtIndex(1).lastObject as! NSDictionary)["y"]!.doubleValue
        let rawChannel1 = (data.objectAtIndex(0).lastObject as! NSDictionary)["rawy"]!.doubleValue
        let rawChannel2 = (data.objectAtIndex(1).lastObject as! NSDictionary)["rawy"]!.doubleValue
        let timestamp = (data.objectAtIndex(0).lastObject as! NSDictionary)["timestamp"]!
        
        graphView1.addData([channel1, channel2])
        graphView2.addData([channel1, channel2])
        graphView3.addData([rawChannel1, rawChannel2])
        
        
        if listenSocket != nil {
            if writeOK {
                for socket in connectedSockets! {
                    let status = "\(channel1),\(channel2),\(rawChannel1),\(rawChannel2),\(timestamp)\n\r".dataUsingEncoding(NSUTF8StringEncoding)
                    socket.writeData(status, withTimeout: -1, tag: 1)
                    
    //                print(String(data: status!, encoding: NSUTF8StringEncoding))
                }
                writeOK = false
            }
        }

    }
    
    func DAQerrorAppeared(string: String!) {
        print(string)
    }

    @IBAction func ActivateServer(sender: AnyObject) {
        let button = sender as! NSButton
        
        if (button.state == NSOnState) {
            let port = 6353
            
            var address = "STARTUP ERROR"
            var interfaces : UnsafeMutablePointer<ifaddrs> = nil
            var temp_addr : UnsafeMutablePointer<ifaddrs> = nil
            var success : Int32 = 0
            // retrieve the current interfaces - returns 0 on success

            success = getifaddrs(&interfaces)
            if success == 0 {
                // Loop through linked list of interfaces
                temp_addr = interfaces;
                while(temp_addr != nil)
                {
                    if(Int32(temp_addr.memory.ifa_addr.memory.sa_family) == AF_INET)
                    {
                        // Check if interface is en0 which is the wifi connection on the iPhone
    //                    print(String.fromCString(temp_addr.memory.ifa_name))
                        if String.fromCString(temp_addr.memory.ifa_name) == "en0" || String.fromCString(temp_addr.memory.ifa_name) == "en1"
                        {
    //                        There exists functions called withUnsafePointer() and withUnsafeMutablePointer() (and variants of these) that give you a pointer to a value that's valid for a nested scope. That's the supported way of working with pointers, but holding onto the pointer after the scope is over is a violation of the language semantics.
                            let addr4 = withUnsafePointer(&temp_addr.memory.ifa_addr.memory) { UnsafePointer<sockaddr_in>($0).memory }
                            // Get String from C String
                            address = String(CString: inet_ntoa(addr4.sin_addr), encoding: NSUTF8StringEncoding)!
                        } else if address != "STARTUP ERROR" {
                            address = "ONLINE : \(address) : \(port)"
                            break
                        }
                    }
                    
                    temp_addr = temp_addr.memory.ifa_next
                }
            }
        
            interfaces = nil
            socketQueue = dispatch_queue_create("socketQueue", nil)
            listenSocket = GCDAsyncSocket(delegate: self, delegateQueue: socketQueue)
            //setup an array to store all accepted client connections
            connectedSockets = Array<GCDAsyncSocket>()
            
            do {
              try listenSocket?.acceptOnInterface("localhost", port: 6353)
            }
            catch let error as NSError {
              print("error starting server : \(port) because \(error)");
              return
            }
            
            print("server started on port : \(port)");
            button.title = "Stop"
        }
        else {
            terminateServer()
            button.title = "Server"
        }

    }
    //MARK: CocoaAsyncSocketDelegates

    func socket(sock: GCDAsyncSocket!, didAcceptNewSocket newSocket: GCDAsyncSocket!) {
        objc_sync_enter(connectedSockets)
        defer { objc_sync_exit(connectedSockets) }
        
        connectedSockets?.append(newSocket)
        let host = newSocket.connectedHost
        let socketPort = newSocket.connectedPort
        
        dispatch_async(dispatch_get_main_queue(), {
            autoreleasepool {
                for socket in self.connectedSockets! {
                    let writeOutData = "Initiate:\(self.numberOfChannels):\(self.samplingRate):\(self.dataReader!.fileName):\(self.dataReader!.fileName_raw)\n\r".dataUsingEncoding(NSUTF8StringEncoding)
                    socket.writeData(writeOutData!, withTimeout: -1, tag: 1)
//                    print(String(data: writeOutData!, encoding: NSUTF8StringEncoding))
                }
                print("Accepted client : \(host) \(socketPort)")
            }
        })
    }
    
    func socket(sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        sock.readDataToData(GCDAsyncSocket.CRLFData(), withTimeout: -1, tag: tag)
    }
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {

        dispatch_async(dispatch_get_main_queue(), {
            autoreleasepool {
                let response = String(data: data, encoding: NSUTF8StringEncoding)
//                print(response)
                if response!.containsString("Ack") {
                    self.writeOK = true
                }
            }
        })
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        objc_sync_enter(connectedSockets)
        defer { objc_sync_exit(connectedSockets) }
        
        if let index = connectedSockets?.indexOf(sock) {
            connectedSockets?.removeAtIndex(index)
        }
    }
    
    func applicationWillTerminate() {
        terminateServer()
        self.dataReader?.stop()
    }
    
    private func terminateServer() {
        guard let sockets = connectedSockets else { return }
        // Stop accepting connections
    
        objc_sync_enter(connectedSockets)
        defer { objc_sync_exit(connectedSockets) }
        
        for socket in sockets {
            socket.writeData("Shutting down server".dataUsingEncoding(NSUTF8StringEncoding), withTimeout: -1, tag: 1)
            socket.disconnectAfterReadingAndWriting()
        }
        
        listenSocket?.disconnectAfterReadingAndWriting()

        
        print("Server terminated")
    }
    
}

