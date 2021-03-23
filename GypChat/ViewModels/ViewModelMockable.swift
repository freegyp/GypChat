//
//  ViewModelMockable.swift
//  GypChat
//
//  Created by Yupeng Gu on 3/23/21.
//

import Foundation

import Combine
import SwiftUI

class ViewModelMockable<T>:ObservableObject where T:ObservableObject{
    @Published var model:T
    private var anyCancellable: AnyCancellable? = nil
    init(_ model:T) {
        self.model = model
        anyCancellable = model.objectWillChange.sink{[weak self]_ in
            self?.objectWillChange.send()
        }
    }
}
