//
//  ViewController.swift
//  SMKTunes
//
//  Created by Kalanyu Zintus-art on 10/21/15.
//  Copyright © 2015 KoikeLab. All rights reserved.
//

import Cocoa
import CocoaAsyncSocket
import SwiftR
import Foundation
import MapKit

@IBDesignable class ViewController: NSViewController, RoundProgressProtocol, GCDAsyncSocketDelegate {

    
    @IBOutlet weak var computedGraphView: SRPlotView! {
        didSet {
            computedGraphView.title = "Computed"
            computedGraphView.totalSecondsToDisplay = 10
            computedGraphView.totalChannelsToDisplay = 3
            computedGraphView.yTicks[0] = "x"
            computedGraphView.yTicks[1] = "y"
            computedGraphView.yTicks[2] = "z"
            computedGraphView.axeLayer?.maxDataRange = 25
        }
    }
    //, NIDAQreaderProtocol, GCDAsyncSocketDelegate
    @IBOutlet weak var graphView1: SRMergePlotView! {
        didSet {
            graphView1.title = "Gravity"
            graphView1.totalSecondsToDisplay = 10.0
            graphView1.maxDataRange = 12
        }
    }
    @IBOutlet weak var graphView2: SRPlotView! {
        didSet {
            graphView2.title = "Accelerometer"
            graphView2.totalSecondsToDisplay = 10.0
            graphView2.totalChannelsToDisplay = 3
            graphView2.yTicks[0] = "x"
            graphView2.yTicks[1] = "y"
            graphView2.yTicks[2] = "z"
            graphView2.axeLayer?.maxDataRange = 25
        }
    }
    @IBOutlet weak var graphView3: SRMergePlotView! {
        didSet {
            graphView3.title = "Rotation"
            graphView3.totalSecondsToDisplay = 10.0
            graphView3.maxDataRange = 2
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var backgroundView: SRSplashBGView! {
        didSet {
            backgroundView.splashFill(toColor: NSColor(red: 1/255.0, green: 71/255.0, blue: 64/255.0, alpha: 1), .left)
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
    

    
    private var anotherDataTimer: Timer?
    var count = 0
    
    private let loadingView = SRSplashBGView(frame: CGRect.zero)
    private var loadingLabel = NSTextLabel(frame: CGRect.zero)
    private var loadingText = "Status : Waiting for connection" {
        didSet {
            loadingLabel.stringValue = self.loadingText
            loadingLabel.sizeToFit()
        }
    }
    private let progressIndicator = NSProgressIndicator(frame: CGRect.zero)
    private var fakeLoadTimer: Timer?
    private var listenSocket : GCDAsyncSocket?
    private var socketQueue : DispatchQueue?
    private var connectedSockets : Array<GCDAsyncSocket>?
    private var writeOK = false
    private var numberOfChannels = 2;
    private var samplingRate = 1;

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //prepare loading screen
        loadingView.frame = self.view.frame
        progressIndicator.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100))
        progressIndicator.style = .spinning
        loadingLabel.frame = CGRect(origin: CGPoint(x: progressIndicator.frame.origin.x + progressIndicator.frame.width, y: 0), size: CGSize(width: 100, height: 100))
        loadingLabel.stringValue = loadingText
        loadingLabel.font = NSFont.boldSystemFont(ofSize: 15)
        loadingLabel.sizeToFit()
        loadingLabel.frame.origin.y = progressIndicator.frame.origin.y + (progressIndicator.frame.width/2) - (loadingLabel.frame.height/2)
        loadingLabel.lineBreakMode = .byTruncatingTail


        loadingView.addSubview(loadingLabel)
        loadingView.addSubview(progressIndicator)
        progressIndicator.startAnimation(nil)
        loadingView.wantsLayer = true
        loadingView.layer?.backgroundColor = NSColor.white.cgColor

        loadingView.autoresizingMask = [.height, .width]
        self.view.addSubview(loadingView)
        //drivemode offices
//        35.7014553,139.7086263,18.13z
        let location = CLLocation(latitude: 35.7014553, longitude: 139.7086263)
        let coordinate = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000)
        mapView.setRegion(coordinate, animated: true)
//        anotherDataTimer = Timer(timeInterval:1/20, target: self, selector: "addData2", userInfo: nil, repeats: true)
//        RunLoop.current.add(anotherDataTimer!, forMode: RunLoopMode.commonModes)
////
////        iController.delegate = self
////        currentTrackLabel.stringValue = "Track: ".stringByAppendingString(iController.currentTrackName())
////        volumeView.countText = String(format: "%2d", iController.currentVolume())
////        artworkView.image = iController.currentTrackAlbumArt()
////        currentStatusLabel.stringValue = "Status: ".stringByAppendingString(iController.currentStatus())
////        artistField.stringValue = "Artist: \(iController.currentArtist())"
////        commandField.stringValue = "Waiting"
////        // Do any additional setup after loading the view.
////        
////        motionSensor.delegate = self
////        motionSensor.scanForRemoteSensor()
//        graphView1.maxDataRange = 1
//        graphView1.totalChannelsToDisplay = 2
//        
//        graphView2.totalChannelsToDisplay = 2
//        
//        graphView3.maxDataRange = 1
//        graphView3.totalChannelsToDisplay = 2
//        
////        motionClassifier.delegate = self
        fakeLoadTimer = Timer(timeInterval: 3, target: self, selector: #selector(systemStartup), userInfo: nil, repeats: false)
        RunLoop.current.add(fakeLoadTimer!, forMode: RunLoopMode.commonModes)

    }
    
    override func viewWillDisappear() {
        
    }
    
    @objc func systemStartup() {
        loadingView.fade(toAlpha: 0)
    }

    
    @objc func addData2() {
        count += 1
        let cgCount = sin(Double(count) * 1/20) * 15000
        //            let cgCount = 0.0
        graphView1.addData([cgCount+1000, cgCount+2000, cgCount+3000, cgCount+400, cgCount+500 , cgCount+600])
        graphView2.addData([cgCount+1000, cgCount+2000, cgCount+3000, cgCount+400, cgCount+500 , cgCount+600])
        graphView3.addData([cgCount+1000, cgCount+2000, cgCount+3000, cgCount+400, cgCount+500 , cgCount+600])

    }
    
    
//    @IBAction func Rectify(sender: NSButton) {
//        guard let reader = dataReader else { return }
//
//        if (!reader.rectify) {
//            sender.title = "Rectified"
//        } else {
//            sender.title = "Rectify"
//        }
//
//        reader.rectify = !reader.rectify;
//    }
//
    func roundProgressClicked(_ sender: NSView) {
//        if (sender === baseAlignButton) {
//            dataReader?.activateZscore(withBufferSize: Int32(samplingRate) * 2);
//        } else if(sender === normalizeButton) {
////            serverButton.enabled = !serverButton.enabled
//            dataReader?.activateNormalization(withBufferSize: Int32(samplingRate) * 5);
//
//        } else if(sender === filterButton) {
//            dataReader?.activateKoikefilter(withSamplingRate: Int32(samplingRate));
//        } else if(sender === lowpassButton) {
//            //just copy past from matlab
////            var b = [0.00002914, 0.00008743, 0.00008743, 0.00002914];
////            var a = [-2.8744, 2.7565, -0.8819];
////            var b = [0.0029, 0.0087, 0.0087, 0.0029];
//
//            var b = [0.0000000000003029, 0.0000000000015145, 0.0000000000030289, 0.0000000000030289, 0.0000000000015145, 0.0000000000003029]
//            var a = [1.0000000000000000, -4.9796671949900722, 9.9188753381375463, -9.8786215487796287, 4.9192858681237484, -0.9798724624819012]
//
//            dataReader?.activateLowpassFilter(withCoefficients: &b, andDenominator: &a, withOrder: Int32(a.count - 1))
//        }
    }
    
    func incomingStream(_ type: String, data: [Double]) {
        switch type {
        case "acceleration":
            graphView2.addData(Array(data[..<3]))
        case "gyroscope":
            graphView1.addData(Array(data[..<3]))
        case "rotation":
            graphView3.addData(Array(data[..<3]))
        default:
            break
        }
    }

    @IBAction func ActivateServer(sender: AnyObject) {
        let button = sender as! NSButton

        if (button.state == NSControl.StateValue.on) {
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
                    if(Int32(temp_addr!.pointee.ifa_addr.pointee.sa_family) == AF_INET)
                    {
                        if String(cString: temp_addr!.pointee.ifa_name) == "en0" || String(cString: temp_addr!.pointee.ifa_name) == "en1"
                        {
    //                        There exists functions called withUnsafePointer() and withUnsafeMutablePointer() (and variants of these) that give you a pointer to a value that's valid for a nested scope. That's the supported way of working with pointers, but holding onto the pointer after the scope is over is a violation of the language semantics.
                            let addr4 = withUnsafePointer(to: &temp_addr!.pointee.ifa_addr.pointee) {
                                $0.withMemoryRebound(to: sockaddr_in.self, capacity: 1) {
                                    $0.pointee
                                }
                            }
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
            socketQueue = DispatchQueue(label: "socketQueue")
            listenSocket = GCDAsyncSocket(delegate: self as GCDAsyncSocketDelegate, delegateQueue: socketQueue)
            //setup an array to store all accepted client connections
            connectedSockets = Array<GCDAsyncSocket>()

            do {
                try listenSocket?.accept(onInterface: "10.0.1.91", port: 56739)
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
            DispatchQueue.main.async {
                self.terminateServer()
            }
            addressLabel.title = "OFFLINE";

            button.title = "Server"
        }

    }
    
    //MARK: CocoaAsyncSocketDelegates
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        objc_sync_enter(connectedSockets!)
        defer { objc_sync_exit(connectedSockets!) }

        connectedSockets?.append(newSocket)
        let host = newSocket.connectedHost
        let socketPort = newSocket.connectedPort
        for _ in self.connectedSockets! {
                newSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: 100, tag: 1)
            }
        print("Accepted client : \(String(describing: host)) \(String(describing:socketPort))")
    }

    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        sock.readData(to: GCDAsyncSocket.crlfData(), withTimeout: 100, tag: tag)
    }

    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let response = String(data: data as Data, encoding: String.Encoding.utf8)
        if response!.contains("Eject\r\n") {
            sock.disconnectAfterReadingAndWriting()
            return
        }

        if let res = response?.contains("data"), let text = response, res {
            let pattern = "(data).*?(value)[^data]*"
            let regex = try! NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: text, range: NSMakeRange(0, text.utf16.count))
            let packets = matches.map {String(text[Range($0.range, in: text)!])}
            
            for signal in packets {
                var type = signal.components(separatedBy: ",").first
                type = type?.components(separatedBy: ":").last
                
                let comps = signal.components(separatedBy: ":").last
                let numbers = comps!.components(separatedBy: ",").map { (text) in (text.trimmingCharacters(in: .whitespacesAndNewlines) as NSString).doubleValue }
                
//                print("\(String(describing: type)), \(numbers)")
            
                DispatchQueue.main.async {
                    self.incomingStream(type!, data: numbers)
                }
            }
            
        }
        let status = "Received\r\n".data(using: String.Encoding.utf8)
        sock.write(status!, withTimeout: 100, tag: 1)
    }

    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        objc_sync_enter(connectedSockets!)
        defer { objc_sync_exit(connectedSockets!) }

        if let index = connectedSockets?.index(of:sock) {
            connectedSockets?.remove(at:index)
        }
    }

    func applicationWillTerminate() {
        terminateServer()
    }

    private func terminateServer() {
        guard let sockets = connectedSockets else { return }
        // Stop accepting connections
        objc_sync_enter(connectedSockets!)
        defer { objc_sync_exit(connectedSockets!) }

        for socket in sockets {
            socket.write("Eject\r\n".data(using: String.Encoding.utf8), withTimeout: 100, tag: 1)
            socket.disconnectAfterReadingAndWriting()
        }
        listenSocket?.disconnectAfterReadingAndWriting()
        print("Server terminated")
    }

}

