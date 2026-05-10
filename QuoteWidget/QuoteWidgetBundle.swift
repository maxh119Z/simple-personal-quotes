//
//  QuoteWidgetBundle.swift
//  QuoteWidget
//
//  Created by Max Zhang on 5/9/26.
//

import WidgetKit
import SwiftUI

@main
struct QuoteWidgetBundle: WidgetBundle {
    var body: some Widget {
        QuoteWidget()
        QuoteWidgetControl()
    }
}
