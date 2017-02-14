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
            backgroundView.splashFill(toColor: NSColor(red: 241/255.0, green: 206/255.0, blue: 51/255.0, alpha: 1), .left)
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
            baseAlignButton.loadSeconds = 2.0
        }
    }
    
    @IBOutlet weak var filterButton: RoundProgressView! {
        didSet {
            filterButton.roundDelegate = self
            filterButton.title = "Filter"
            filterButton.loadSeconds = 1.0
        }
    }
    @IBOutlet weak var normalizeButton: RoundProgressView! {
        didSet {
            normalizeButton.roundDelegate = self
            normalizeButton.showMarker = true
            normalizeButton.title = "Norm"
            normalizeButton.loadSeconds = 5.0
        }
    }
    
    @IBOutlet weak var lowpassButton: RoundProgressView! {
        didSet {
            lowpassButton.roundDelegate = self
            lowpassButton.title = "Lowpass"
            lowpassButton.loadSeconds = 0.5
        }
    }

    @IBOutlet weak var serverButton: NSButton!
    @IBOutlet weak var rectifyButton: NSButton! {
        didSet {
            rectifyButton.isEnabled = false
            rectifyButton.title = "Rectify"
        }
    }
    @IBOutlet weak var addressLabel: NSButton!
    

    
    fileprivate var anotherDataTimer: Timer?
    var count = 0
    
    fileprivate var dataReader : NIDAQreader?
    fileprivate let loadingView = NSSpashBGView(frame: CGRect.zero)
    fileprivate var loadingLabel = NSTextLabel(frame: CGRect.zero)
    fileprivate var loadingText = "Status : Waiting for connection" {
        didSet {
            loadingLabel.stringValue = self.loadingText
            loadingLabel.sizeToFit()
        }
    }
    fileprivate let progressIndicator = NSProgressIndicator(frame: CGRect.zero)
    fileprivate var fakeLoadTimer: Timer?
    fileprivate var listenSocket : GCDAsyncSocket?
    fileprivate var socketQueue : DispatchQueue?
    fileprivate var connectedSockets : Array<GCDAsyncSocket>?
    fileprivate var writeOK = false
    fileprivate var numberOfChannels = 2;
    fileprivate var samplingRate = 1000;

    
    
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

        
        anotherDataTimer = Timer(timeInterval:1/60, target: self, selector: #selector(ViewController.addData2), userInfo: nil, repeats: true)
        RunLoop.current.add(anotherDataTimer!, forMode: RunLoopMode.commonModes)
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
        count += 1
        let cgCount = sin(Double(count) * 1/60)
        //            let cgCount = 0.0
        graphView1.addData([cgCount, cgCount+1, cgCount+2, cgCount+3, cgCount+4 , cgCount+5])
        graphView2.addData([cgCount, cgCount+1, cgCount+2, cgCount+3, cgCount+4 , cgCount+5])
        graphView3.addData([cgCount, cgCount+1, cgCount+2, cgCount+3, cgCount+4 , cgCount+5])

    }
    
    
    @IBAction func Rectify(_ sender: NSButton) {
        guard let reader = dataReader else { return }
        
        if (!reader.rectify) {
            sender.title = "Rectified"
        } else {
            sender.title = "Rectify"
        }
            
        reader.rectify = !reader.rectify;
    }
    
    func roundProgressClicked(_ sender: NSView) {
        if (sender === baseAlignButton) {
            dataReader?.activateZscore(withBufferSize: Int32(samplingRate) * 2);
        } else if(sender === normalizeButton) {
//            serverButton.enabled = !serverButton.enabled
            dataReader?.activateNormalization(withBufferSize: Int32(samplingRate) * 5);

        } else if(sender === filterButton) {
            dataReader?.activateKoikefilter(withSamplingRate: Int32(samplingRate));
        } else if(sender === lowpassButton) {
            //just copy past from matlab
//            var b = [0.00002914, 0.00008743, 0.00008743, 0.00002914];
//            var a = [-2.8744, 2.7565, -0.8819];
//            var b = [0.0029, 0.0087, 0.0087, 0.0029];
            
            var b = [0.0000000000003029, 0.0000000000015145, 0.0000000000030289, 0.0000000000030289, 0.0000000000015145, 0.0000000000003029]
            var a = [1.0000000000000000, -4.9796671949900722, 9.9188753381375463, -9.8786215487796287, 4.9192858681237484, -0.9798724624819012]
            
            dataReader?.activateLowpassFilter(withCoefficients: &b, andDenominator: &a, withOrder: Int32(a.count - 1))
        }
    }
    
    
    @IBAction func ReadFromDAQ(_ sender: NSButton) {
        if (sender.state == NSOnState) {
            sender.title = "Stop"
            //slider from 1 to 6 channels
            //        self.dataReader = [[[NIDAQreader alloc] initWithNumberOfChannels:[channelSlider intValue] andSamplingRate:[dataRateSlider intValue]] autorelease];
            dataReader = NIDAQreader(numberOfChannels: Int32(numberOfChannels), andSamplingRate: Int32(samplingRate));

            dataReader!.delegate = self;
            
            var b = [0.9918, -3.9673, 5.9509, -3.9673, 0.9918]
            var a = [1.0000, -3.9836, 5.9509, -3.9510, 0.9837]
            dataReader?.activateHighpassFilter(withCoefficients: &b, andDenominator: &a, withOrder: Int32(a.count - 1))

            //        NSLog(@"%d channel %d sample rate",[channelSlider intValue], [dataRateSlider intValue]);

            //TODO: add delegate to announce error
            //specify sampling rate as an argument
            let operationQueue = OperationQueue()
            operationQueue.addOperation({
                self.dataReader?.startCollection()
            })
            
            rectifyButton.isEnabled = true
        }
        else {
            self.dataReader?.stop()
//            serverButton.enabled = false
            rectifyButton.isEnabled = false
            sender.title = "Read"
        }
    }

    func incomingStream(_ data: NSMutableArray!) {
        let channel1 = (((data.object(at: 0) as AnyObject).lastObject as! NSDictionary)["y"]! as AnyObject).doubleValue!
        let channel2 = (((data.object(at: 1) as AnyObject).lastObject as! NSDictionary)["y"]! as AnyObject).doubleValue!
        let rawChannel1 = (((data.object(at: 0) as AnyObject).lastObject as! NSDictionary)["rawy"]! as AnyObject).doubleValue!
        let rawChannel2 = (((data.object(at: 1) as AnyObject).lastObject as! NSDictionary)["rawy"]! as AnyObject).doubleValue!
        let timestamp = ((data.object(at: 0) as AnyObject).lastObject as! NSDictionary)["timestamp"]!
        
        graphView1.addData([channel1, channel2])
        graphView2.addData([channel1, channel2])
        graphView3.addData([rawChannel1, rawChannel2])
        
        
        if listenSocket != nil {
            if writeOK {
                for socket in connectedSockets! {
                    let status = "\(channel1),\(channel2),\(rawChannel1),\(rawChannel2),\(timestamp)\n\r".data(using: String.Encoding.utf8)
                    socket.write(status!, withTimeout: -1, tag: 1)
                    
    //                print(String(data: status!, encoding: NSUTF8StringEncoding))
                }
                writeOK = false
            }
        }

    }
    
    func daQerrorAppeared(_ string: String!) {
        print(string)
    }

    @IBAction func ActivateServer(_ sender: AnyObject) {
        let button = sender as! NSButton
        
        if (button.state == NSOnState) {
            let port = 6353
            
            var address = "STARTUP ERROR"
            var interfaces : UnsafeMutablePointer<ifaddrs>? = nil
            var temp_addr : UnsafeMutablePointer<ifaddrs>? = nil
            var success : Int32 = 0
            // retrieve the current interfaces - returns 0 on success

            success = getifaddrs(&interfaces)
            if success == 0 {
                // Loop through linked list of interfaces
                temp_addr = interfaces;
                while(temp_addr != nil)
                {
                    if(Int32((temp_addr?.pointee.ifa_addr.pointee.sa_family)!) == AF_INET)
                    {
                        // Check if interface is en0 which is the wifi connection on the iPhone
    //                    print(String.fromCString(temp_addr.memory.ifa_name))
                        if String(cString: (temp_addr?.pointee.ifa_name)!) == "en0" || String(cString: (temp_addr?.pointee.ifa_name)!) == "en1"
                        {
    //                        There exists functions called withUnsafePointer() and withUnsafeMutablePointer() (and variants of these) that give you a pointer to a value that's valid for a nested scope. That's the supported way of working with pointers, but holding onto the pointer after the scope is over is a vwiolation of the language semantics.
                            let addr4 = withUnsafePointer(to: &temp_addr!.pointee.ifa_addr.pointee) { UnsafeRawPointer($0).load(as: sockaddr_in.self) }
                            // Get String from C String
                            address = String(cString: inet_ntoa(addr4.sin_addr), encoding: String.Encoding.utf8)!
													
                        } else if address != "STARTUP ERROR" {
                            address = "ONLINE : \(address) : \(port)"
                            break
                        }
                    }
                    
                    temp_addr = temp_addr?.pointee.ifa_next
                }
            }
        
            interfaces = nil
            socketQueue = DispatchQueue(label: "socketQueue", attributes: [])
            listenSocket = GCDAsyncSocket(delegate: self, delegateQueue: socketQueue)
            //setup an array to store all accepted client connections
            connectedSockets = Array<GCDAsyncSocket>()
            
            do {
              try listenSocket?.accept(onInterface: "localhost", port: 6353)
            }
            catch let error as NSError {
              print("error starting server : \(port) because \(error)");
              return
            }
            
            print("server started on adress: \(address) ");
            addressLabel.title = address;
            
            button.title = "Stop"
        }
        else {
            terminateServer()
            addressLabel.title = "OFFLINE";

            button.title = "Server"
        }

    }
    //MARK: CocoaAsyncSocketDelegates

    func socket(_ sock: GCDAsyncSocket!, didAcceptNewSocket newSocket: GCDAsyncSocket!) {
        objc_sync_enter(connectedSockets)
        defer { objc_sync_exit(connectedSockets) }
        
        connectedSockets?.append(newSocket)
        let host = newSocket.connectedHost
        let socketPort = newSocket.connectedPort
        
        DispatchQueue.main.async(execute: {
            autoreleasepool {
                for socket in self.connectedSockets! {
                    let writeOutData = "Initiate:\(self.numberOfChannels):\(self.samplingRate):\(self.dataReader!.fileName):\(self.dataReader!.fileName_raw)\n\r".data(using: String.Encoding.utf8)
                    socket.write(writeOutData!, withTimeout: -1, tag: 1)
//                    print(String(data: writeOutData!, encoding: NSUTF8StringEncoding))
                }
                print("Accepted client : \(host) \(socketPort)")
            }
        })
    }
    
    func socket(_ sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        sock.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: tag)
    }
    
    func socket(_ sock: GCDAsyncSocket!, didRead data: Data!, withTag tag: Int) {

        DispatchQueue.main.async(execute: {
            autoreleasepool {
                let response = String(data: data, encoding: String.Encoding.utf8)
//                print(response)
                if response!.contains("Ack") {
                    self.writeOK = true
                }
            }
        })
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket!, withError err: NSError!) {
        objc_sync_enter(connectedSockets)
        defer { objc_sync_exit(connectedSockets) }
        
        if let index = connectedSockets?.index(of: sock) {
            connectedSockets?.remove(at: index)
        }
    }
    
    func applicationWillTerminate() {
        terminateServer()
        self.dataReader?.stop()
    }
    
    fileprivate func terminateServer() {
        guard let sockets = connectedSockets else { return }
        // Stop accepting connections
    
        objc_sync_enter(connectedSockets)
        defer { objc_sync_exit(connectedSockets) }
        
        for socket in sockets {
            socket.write("Shutting down server".data(using: String.Encoding.utf8)!, withTimeout: -1, tag: 1)
            socket.disconnectAfterReadingAndWriting()
        }
        
        listenSocket?.disconnectAfterReadingAndWriting()

        
        print("Server terminated")
    }
    
}

