/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Respond to asynchronous callbacks throughout gameplay.
*/
import TabletopKit
import RealityKit

class GameObserver: TabletopGame.Observer {
    let tabletop: TabletopGame
    let renderer: GameRenderer

    init(tabletop: TabletopGame, renderer: GameRenderer) {
        self.tabletop = tabletop
        self.renderer = renderer
    }

    func actionIsPending(_ action: some TabletopAction, oldSnapshot: TableSnapshot, newSnapshot: TableSnapshot) {
        if let action = action as? MoveEquipmentAction {
            if let (die, _) = newSnapshot.equipment(of: Die.self, matching: action.equipmentID) {
                Task { @MainActor in
                    die.playTossSound()
                    try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                }
                return
            }
        }
    }

    func actionWasConfirmed(_ action: some TabletopAction, oldSnapshot: TableSnapshot, newSnapshot: TableSnapshot) {
        guard let action = action as? MoveEquipmentAction, let pawn = newSnapshot.equipment(of: Pawn.self, matching: action.equipmentID) else {
            return
        }
    }
}
