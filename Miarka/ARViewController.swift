//
//  ARViewController.swift
//  MultiTool
//
//  Created by Arkadiusz Staśczak on 10.02.2018.
//  Copyright © 2018 Arkadiusz Staśczak. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var measureSceneView: ARSCNView!
    @IBOutlet weak var arTextView: UITextView!
    
    var box: Box!
    var status: String! = "NIEGOTOWY"
    var startPosition: SCNVector3!
    var distance: Float!
    var trackingState: ARCamera.TrackingState!
    
    // Tryb
    enum Mode {
        case waitingForMeasuring
        case measuring
    }

    var mode: Mode = .waitingForMeasuring {
        didSet {
            switch mode {
            case .waitingForMeasuring:
                break
            case .measuring:
                box.update(
                    minExtents: SCNVector3Zero, maxExtents: SCNVector3Zero)
                box.isHidden = false
                startPosition = nil
                distance = 0.0
                setStatusText()
            }
        }
    }
    
    // Stan Śledzenia
    func getTrackigDescription() -> String {
        var description = ""
        if let t = trackingState {
            switch(t) {
            case .notAvailable:
                description = "ŚLEDZENIE NIEMOŻLIWE"
            case .normal:
                description =  "ŚLEDZENIE W NORMIE"
            case .limited(let reason):
                switch reason {
                case .excessiveMotion:
                    description =
                    "ŚLEDZENIE OGRANICZONE - Zbyt dużo ruchów aparatem"
                case .insufficientFeatures:
                    description =
                    "ŚLEDZENIE OGRANICZONE - Nie wykryto odpowieniej ilości powierzchni"
                case .initializing:
                    description = "INICJALIZACJA"
                }
            }
        }
        return description
    }
    
    
    
    func setStatusText() {
        var text = "Status: \(status!)\n"
        text += "Śledzenie: \(getTrackigDescription())\n"
        text += "Odległość: \(String(format:"%.2f cm", distance! * 100.0))"
        arTextView.text = text
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        measureSceneView.delegate = self
        arTextView.textContainerInset =
            UIEdgeInsetsMake(20.0, 10.0, 10.0, 0.0)
        // Inicjalizacja Boxa
        box = Box()
        box.isHidden = true;
        measureSceneView.scene.rootNode.addChildNode(box)
        // Inicjalizacja trybu
        mode = .waitingForMeasuring
        // Inicjalizacja dystansu
        distance = 0.0
        // Wyświetl status
        setStatusText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        measureSceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        measureSceneView.session.pause()
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        trackingState = camera.trackingState
    }
    
    // Wywołanie funkcji mierzenia przy każdorazowym update
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.measure()
        }
    }
    
    
    // Funkcja odpowiedzialna za pmiar
    func measure() {
        let screenCenter : CGPoint = CGPoint(
            x: self.measureSceneView.bounds.midX, y: self.measureSceneView.bounds.midY)
        let planeTestResults = measureSceneView.hitTest(screenCenter, types: [.existingPlaneUsingExtent])
        
        // Po wykryciu pierwsze powierzchni przez ARKit
        if let result = planeTestResults.first {
            status = "GOTOWY"
            if mode == .measuring {
                status = "MIERZĘ"
                let worldPosition = SCNVector3Make(
                    result.worldTransform.columns.3.x,
                    result.worldTransform.columns.3.y,
                    result.worldTransform.columns.3.z
                )
                if startPosition == nil {
                    startPosition = worldPosition
                    box.position = worldPosition
                }
                distance = calculateDistance(from: startPosition!, to: worldPosition)
                
                box.resizeTo(extent: distance)
                let angleInRadians = calculateAngleInRadians( from: startPosition!, to: worldPosition)
                box.rotation = SCNVector4(x: 0, y: 1, z: 0,w: -(angleInRadians + Float.pi))
        }
    }
    setStatusText()
        
    }
    
    
    // Mierzenie odleglosci pomiędzy poczatkiem a obecnym punktem
    func calculateDistance(from: SCNVector3, to: SCNVector3) -> Float {
        let x = from.x - to.x
        let y = from.y - to.y
        let z = from.z - to.z
        return sqrtf( (x * x) + (y * y) + (z * z))
    }
    
    // Mierzenie kąta nachylenia miary
    func calculateAngleInRadians(from: SCNVector3, to: SCNVector3) -> Float {
        let x = from.x - to.x
        let z = from.z - to.z
        return atan2(z, x)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Obsluga przelacznika do mierzenia
    @IBAction func switchEnabled(_ sender: Any) {
        if (sender as AnyObject).isOn {
            mode = .measuring
        } else {
            mode = .waitingForMeasuring
        }
    }

}

class Box : SCNNode {
    lazy var box: SCNNode = makeBox()
    
    override init() {
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // Stworz box
    func makeBox() -> SCNNode {
        let box = SCNBox(
            width: 0.01, height: 0.001, length: 0.01, chamferRadius: 0
        )
        return convertToNode(geometry: box)
    }
    // Konwersja na Node czytany przez ARKit
    func convertToNode(geometry: SCNGeometry) -> SCNNode {
        for material in geometry.materials {
            material.lightingModel = .constant
            material.diffuse.contents = UIImage(named: "ruler")
            material.isDoubleSided = false
        }
        let node = SCNNode(geometry: geometry)
        self.addChildNode(node)
        return node
    }
    
    func resizeTo(extent: Float) {
        var (min, max) = boundingBox
        max.x = extent
        update(minExtents: min, maxExtents: max)
    }
    
    func update(minExtents: SCNVector3, maxExtents: SCNVector3) {
        guard let scnBox = box.geometry as? SCNBox else {
            fatalError("Geometry is not SCNBox")
        }
        
        // Ustaw granice boxa
        let absMin = SCNVector3(
            x: min(minExtents.x, maxExtents.x),
            y: min(minExtents.y, maxExtents.y),
            z: min(minExtents.z, maxExtents.z)
        )
        let absMax = SCNVector3(
            x: max(minExtents.x, maxExtents.x),
            y: max(minExtents.y, maxExtents.y),
            z: max(minExtents.z, maxExtents.z)
        )
        
        // Ustaw wartosci
        boundingBox = (absMin, absMax)
        // Oblicz długość
        let size = absMax - absMin
        // Weź wartośc bezwzględną
        let absDistance = CGFloat(abs(size.x))
        // Dlugosc boxa to ta wartosc
        scnBox.width = absDistance
        let offset = size.x * 0.5
        let vector = SCNVector3(x: absMin.x, y: absMin.y, z: absMin.z)
        box.position = vector + SCNVector3(x: offset, y: 0, z: 0)
    
}
}

// Przeciażenie operatorów + i - dla wektorów
func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(
        left.x + right.x, left.y + right.y, left.z + right.z
    )
}
func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(
        left.x - right.x, left.y - right.y, left.z - right.z
    )
}
