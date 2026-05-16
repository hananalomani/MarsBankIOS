import SwiftUI
import SceneKit

struct MarsPlanetView: UIViewRepresentable {

    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        let scene = SCNScene()

        let sphere = SCNSphere(radius: 1.3)
        sphere.segmentCount = 96

        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "marsTexture")
        sphere.materials = [material]

        let planetNode = SCNNode(geometry: sphere)
        scene.rootNode.addChildNode(planetNode)

        let rotation = CABasicAnimation(keyPath: "rotation")
        rotation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Double.pi * 2))
        rotation.duration = 13
        rotation.repeatCount = .infinity
        planetNode.addAnimation(rotation, forKey: "marsRotation")

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 5)
        scene.rootNode.addChildNode(cameraNode)

        sceneView.scene = scene
        sceneView.allowsCameraControl = true
        sceneView.backgroundColor = .clear
        sceneView.autoenablesDefaultLighting = true

        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}
}
