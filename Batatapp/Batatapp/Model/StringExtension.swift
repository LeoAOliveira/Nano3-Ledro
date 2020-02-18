//
//  StringExtension.swift
//  Batatapp
//
//  Created by Pedro Giuliano Farina on 18/02/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
