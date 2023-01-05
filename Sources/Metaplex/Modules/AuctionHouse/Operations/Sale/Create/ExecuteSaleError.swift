//
//  ExecuteSaleError.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/28/22.
//

import Foundation

public enum ExecuteSaleError: Error {
    case auctionHouseMismatchError
    case mintMismatchError
    case bidCancelledError
    case listingCancelledError
    case auctioneerRequiredError
    case partialSaleUnsupportedError
}
