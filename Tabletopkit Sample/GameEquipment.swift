/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A declaration of every equipment type used in the game.
*/
import TabletopKit
import RealityKit
import TabletopGameSampleContent
import Spatial

extension EquipmentIdentifier {
    static var tableID: Self { .init(0) }
}

struct Table: Tabletop {
    var shape: TabletopShape = .rectangular(width: GameMetrics.tableEdge, height: GameMetrics.tableEdge, thickness: 0)
    
    var id: EquipmentIdentifier = .tableID
}

struct Board: Equipment {
    let id: ID

    var initialState: BaseEquipmentState {
        .init(parentID: .tableID,
              seatControl: .restricted([]),
              pose: .init(position: .init(), rotation: .degrees(45)),
              boundingBox: .init(center: .zero, size: .init(GameMetrics.boardEdge, GameMetrics.boardHeight, GameMetrics.boardEdge)))
    }
}

struct PlayerSeat: TableSeat {
    let id: ID
    var initialState: TableSeatState

    /* There are three seats around the edges of the table.
    Each seat faces the center of the table. */
    @MainActor static let seatPoses: [TableVisualState.Pose2D] = [
        .init(position: .init(x: 0, z: Double(GameMetrics.tableEdge)), rotation: .degrees(0)),
        .init(position: .init(x: -Double(GameMetrics.tableEdge), z: 0), rotation: .degrees(-90)),
        .init(position: .init(x: Double(GameMetrics.tableEdge), z: 0), rotation: .degrees(90))
    ]
    
    init(id: TableSeatIdentifier, pose: TableVisualState.Pose2D) {
        self.id = id
        let spatialSeatPose: TableVisualState.Pose2D = .init(position: pose.position,
                                                             rotation: pose.rotation)
        initialState = .init(pose: spatialSeatPose)
    }
}

struct Pawn: EntityEquipment {
    let id: ID
    let entity: Entity
    var initialState: BaseEquipmentState
    
    static let pawns: [String] = [
        "Mindflayer",
        "Orc"
    ]
    
    @MainActor
    init(id: ID, seat: PlayerSeat, name: String) {
        self.id = id
        self.entity = try! Entity.load(named: name, in: tabletopGameSampleContentBundle)
        self.entity.scale *= [0.02, 0.02, 0.02]
        let pawnToSeat: TableVisualState.Pose2D = .init(position: .init(x: -0.2, z: -0.3), rotation: .init())
        let seatToTable = seat.initialState.pose
        let pawnToTable = pawnToSeat * seatToTable
        initialState = .init(parentID: .tableID, pose: pawnToTable, entity: self.entity)
    }
}

struct Die: EntityEquipment {
    let id: ID
    let entity: Entity
    let audioPlaybackController: AudioPlaybackController
    var initialState: DieState
    let representation: TossableRepresentation
    
    // Return the orientation of the die entity to a given value face up.
    func restingOrientation(state: DieState) -> Rotation3D {
       // Define orientations for each of the 20 faces of a d20 die.
       switch state.value {
           case 1:
               return .init(angle: .init(degrees: +180), axis: .init(x: 0, y: 0, z: 1)) // Example orientation
           case 2:
               return .init(angle: .init(degrees: +90), axis: .init(x: 0, y: 0, z: 1)) // Example orientation
           case 3:
               return .init(angle: .init(degrees: -90), axis: .init(x: 1, y: 0, z: 0)) // Example orientation
           case 4:
               return .init(angle: .init(degrees: +90), axis: .init(x: 1, y: 0, z: 0)) // Example orientation
           case 5:
               return .init(angle: .init(degrees: -90), axis: .init(x: 0, y: 0, z: 1)) // Example orientation
           case 6:
               return .init() // Example orientation
           // Add orientations for values 7 through 20 here
           case 7:
               return .init(angle: .init(degrees: +45), axis: .init(x: 1, y: 1, z: 0)) // Example orientation
           case 8:
               return .init(angle: .init(degrees: -45), axis: .init(x: 1, y: 1, z: 0)) // Example orientation
           case 9:
               return .init(angle: .init(degrees: +135), axis: .init(x: 1, y: 1, z: 0)) // Example orientation
           case 10:
               return .init(angle: .init(degrees: -135), axis: .init(x: 1, y: 1, z: 0)) // Example orientation
           case 11:
               return .init(angle: .init(degrees: +180), axis: .init(x: 1, y: 1, z: 1)) // Example orientation
           case 12:
               return .init(angle: .init(degrees: +90), axis: .init(x: 1, y: 1, z: 1)) // Example orientation
           case 13:
               return .init(angle: .init(degrees: -90), axis: .init(x: 1, y: 1, z: 1)) // Example orientation
           case 14:
               return .init(angle: .init(degrees: +45), axis: .init(x: 0, y: 1, z: 1)) // Example orientation
           case 15:
               return .init(angle: .init(degrees: -45), axis: .init(x: 0, y: 1, z: 1)) // Example orientation
           case 16:
               return .init(angle: .init(degrees: +135), axis: .init(x: 0, y: 1, z: 1)) // Example orientation
           case 17:
               return .init(angle: .init(degrees: -135), axis: .init(x: 0, y: 1, z: 1)) // Example orientation
           case 18:
               return .init(angle: .init(degrees: +90), axis: .init(x: 0, y: 1, z: 1)) // Example orientation
           case 19:
               return .init(angle: .init(degrees: -90), axis: .init(x: 0, y: 1, z: 1)) // Example orientation
           case 20:
               return .init(angle: .init(degrees: +180), axis: .init(x: 1, y: 1, z: 0)) // Example orientation
           default:
               fatalError("Invalid die value")
       }
    }
    
    @MainActor
    init(id: ID) {
        self.id = id
        self.entity = try! Entity.load(named: "d20", in: tabletopGameSampleContentBundle)
        self.entity.scale *= [0.02, 0.02, 0.02]
        let audioResource = try! AudioFileResource.load(named: "/Root/dieSoundShort_mp3",
                                                        from: "static_scene.usda",
                                                        in: tabletopGameSampleContentBundle)
        self.audioPlaybackController = self.entity.prepareAudio(audioResource)
        representation = .cube(height: entity.visualBounds(relativeTo: nil).extents.x)
        let pose: TableVisualState.Pose2D = .init(position: .init(x: -0.3, z: 0.5), rotation: .zero)
        initialState = .init(value: 1, parentID: .tableID, seatControl: .any, pose: pose, entity: self.entity)
    }

    @MainActor
    func playTossSound() {
        if !audioPlaybackController.isPlaying {
            audioPlaybackController.seek(to: .zero)
            audioPlaybackController.play()
        }
    }
}
