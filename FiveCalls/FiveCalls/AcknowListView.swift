// Copyright 5calls. All rights reserved. See LICENSE for details.

import AcknowList
import SwiftUI

struct AcknowListView: UIViewControllerRepresentable {
    func makeUIViewController(context _: Context) -> AcknowListViewController {
        AcknowListViewController()
    }

    func updateUIViewController(_: AcknowListViewController, context _: Context) {}
}
