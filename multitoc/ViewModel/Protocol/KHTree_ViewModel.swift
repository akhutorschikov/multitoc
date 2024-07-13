//
//  KHTree_ViewModel.swift
//  Multitoc
//
//  Created by Alex Khuala on 24.04.24.
//

import Foundation

protocol KHTree_ViewModelListener: AnyObject
{
    //
}

protocol KHTree_ViewModel
{
    var entries: [KHMainEntry] { get }
    
    func addListener(_ listener: KHTree_ViewModelListener)
    func removeListener(_ listener: KHTree_ViewModelListener)
}
