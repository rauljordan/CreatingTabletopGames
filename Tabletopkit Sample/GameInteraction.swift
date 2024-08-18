/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An object to respond to player interactions and update gameplay.
*/
import TabletopKit
import RealityKit
import Foundation

struct GameInteraction: TabletopInteraction.Delegate {
    let game: Game
    
    mutating func update(interaction: TabletopKit.TabletopInteraction) {
        if interaction.value.phase == .started {
            onPhaseStarted(interaction: interaction)
        }
        
        if interaction.value.gesturePhase == .ended {
            onGesturePhaseEnded(interaction: interaction)
        }

        if interaction.value.phase == .ended {
            onPhaseEnded(interaction: interaction)
        }
    }
    
    func onPhaseStarted(interaction: TabletopInteraction) {
        if game.tabletopGame.equipment(of: Die.self, matching: interaction.value.startingEquipmentID) != nil {
            // Don't let the die land on any other equipment, just the table.
            interaction.setAllowedDestinations(.restricted([]))
        }
        if game.tabletopGame.equipment(of: Pawn.self, matching: interaction.value.startingEquipmentID) != nil {
            interaction.setAllowedDestinations(.any)
        }
    }
    
    func onGesturePhaseEnded(interaction: TabletopInteraction) {
        if let die = game.tabletopGame.equipment(of: Die.self, matching: interaction.value.startingEquipmentID) {
            // Pick a random value for the result of the die toss and toss the die.
            let nextValue = Int.random(in: 1 ... 20)
            interaction.addAction(.updateEquipment(die, state: .init(value: nextValue, parentID: .tableID, entity: die.entity)))
            interaction.toss(equipmentID: interaction.value.startingEquipmentID, as: die.representation)
            interaction.addAction(.moveEquipment(matching: die.id, childOf: .tableID, pose: die.initialState.pose))
        }
    }
    
    func onPhaseEnded(interaction: TabletopInteraction) {
        guard let dst = interaction.value.proposedDestination else {
            return
        }
        if let pawn = game.tabletopGame.equipment(of: Pawn.self, matching: interaction.value.startingEquipmentID) {
            // Move the pawn to its new proposed destination with a default pose (centered in new destination).
            interaction.addAction(.moveEquipment(matching: pawn.id, childOf: .tableID, pose: dst.pose))
        }
        
    }
}
