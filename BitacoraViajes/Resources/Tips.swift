import SwiftUI
import TipKit

public struct CoinFlipTip: Tip {
    public var title: Text {
        Text("Gira tus piezas en 3D")
    }

    public var message: Text? {
        Text("Toca cualquier moneda o billete para voltearlo en 180° y admirar su reverso y relieve.")
    }

    public var image: Image? {
        Image(systemName: "hand.tap.fill")
    }
}
