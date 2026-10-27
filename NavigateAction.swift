import SwiftUI

struct NavigateAction {
    let action: (Email) -> Void

    func callAsFunction(_ email: Email) {
        action(email)
    }
}

extension EnvironmentValues {
    @Entry var izNavigate = NavigateAction { _ in }
}
