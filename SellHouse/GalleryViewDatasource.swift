//
//  MatchesViewDatasource.swift
//  Minifm
//
//  Created by Thomas on 1/7/17.
//  Copyright © 2017 TBL tech nerds. All rights reserved.
//

import UIKit

class GalleryViewDatasource: NSObject, UITableViewDataSource {

    var viewModel : GalleryViewModel?
    
    init( vModel : GalleryViewModel) {
        viewModel = vModel
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : GalleryCell = tableView.dequeueReusableCell(withIdentifier: "GalleryCellId", for: indexPath) as! GalleryCell
        cell.backgroundColor = UIColor.clear
        cell.model = viewModel?.viewModel(at: indexPath.row)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}
