/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Render objects other than equipment.
*/
import TabletopKit
import RealityKit
import SwiftUI
import TabletopGameSampleContent

@MainActor
class GameRenderer: TabletopGame.RenderDelegate {
    let root: Entity = .init()
    // The root offset controls the height of the table inside the app volume.
    let rootOffset: Vector3D = .init(x: 0, y: -0.7, z: 0)
    weak var game: Game?
    
    init() {
        // Move everything down within the volume so the tabletop is easier to see.
        root.transform.translation = .init(rootOffset)
        Task {
            await loadAssets()
        }
    }
    
    func loadAssets() async {
        let staticSceneEntity = try! await Entity(named: "static_scene", in: tabletopGameSampleContentBundle)
        staticSceneEntity.setParent(root)
    }
}
