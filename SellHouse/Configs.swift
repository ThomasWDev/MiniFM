//
//  Configs.swift
//  Minifm
//
//  Created by Thomas on 18/03/16.
//  Copyright © 2016 GF. All rights reserved.
//


import Foundation
import Parse




let APP_NAME = "Minifm" // Your App name

let REPORT_EMAIL_ADDRESS = "report@youremail.com" // Report emails from users, this is required by Apple

let MY_CONTACT_EMAIL = "info@youremail.com" // Email that user use for contact you by form inside the app

let ADMOB_UNIT_AD = "ca-app-pub-3940256099942544/6300978111" //Your AdMob ID

let ONESIGNAL_APP_ID = "c1924d23-8008-42e3-b4f7-f8428c5e0e34" // Your OneSignal ID for Push Notifications


// Your Parse Keys
//Production : Please comment out it when you use in development enviroment
let PARSE_APP_KEY = "RmzLDNd9fT6N7uyonIncQljhjpQS356Si0kYyKcH"
let PARSE_CLIENT_KEY = "daJ5FI3hmuFKjOfkFUmu3RVzP4SGsMbXCj4Iyf7t"
//Staging
//let PARSE_APP_KEY = "OLtJ8En3qDxxlqUL5Z5JygPvRFzJeVq2mNsPeSD6"
//let PARSE_CLIENT_KEY = "zTZfXmE0QaatipJSvJ0LSablGmI27CmvjO8iUvHv"

struct STORYBOARDS {
    static let SIGNIN_STORYBOARD            =   UIStoryboard(name: "SignIn", bundle: nil)
    static let FEED_STORYBOARD           =   UIStoryboard(name: "Feed", bundle: nil)
}

struct TEXT_ATTRIBUTE {
    
    static let navigationBarTextAttribute : [String:AnyObject] = {
        
        let attribute : [String:AnyObject] = [NSForegroundColorAttributeName : UIColor(red: 250/255.0, green: 72/255.0, blue: 91/255.0, alpha: 1.0), NSFontAttributeName : UIFont(name: "Avenir-Light", size: 18)!]
        return attribute
        
    }()
}

struct COLORS {
    
    static let LIGHT_GRAY_COLOR = UIColor(colorLiteralRed: 222.0/255.0, green: 222.0/255.0, blue: 222.0/255.0, alpha: 1.0)
    static let LIGHT_RED_COLOR = UIColor(colorLiteralRed: 250.0/255.0, green: 72.0/255.0, blue: 92.0/255.0, alpha: 1.0)
}

// HUD VIEW
var hudView = UIView()
var animImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
extension UIViewController {
    func showHUD() {
        hudView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        hudView.backgroundColor = UIColor.white
        hudView.alpha = 0.5
        
        let imagesArr = ["h0", "h1", "h2", "h3", "h4", "h5", "h6", "h7", "h8", "h9"]
        var images : [UIImage] = []
        for i in 0..<imagesArr.count {
            images.append(UIImage(named: imagesArr[i])! )
        }
        animImage.animationImages = images
        animImage.animationDuration = 0.7
        animImage.center = hudView.center
        hudView.addSubview(animImage)
        animImage.startAnimating()
        
        view.addSubview(hudView)
    }
    
    func hideHUD() {  hudView.removeFromSuperview()  }
    
    func simpleAlert(_ mess:String) {
        UIAlertView(title: APP_NAME, message: mess, delegate: nil, cancelButtonTitle: "OK").show()
    }
    
}



// Users classes
let USER_CLASS_NAME = "User"
let USER_FULLNAME = "fullName"
let USER_FIRSTNAME = "firstname"
let USER_LASTNAME = "lastname"
let USER_LOCATION = "location"
let USER_BIO = "bio"
let USER_USERNAME = "username"
let USER_AVATAR = "avatar"
let USER_COVER = "cover"
let USER_TEL = "tel"
let USER_MOBILE = "mobile"
let USER_EMAIL = "email"
let USER_SKYPE = "skype"
let USER_FACEBOOK = "facebook"
let USER_TWITTER = "twitter"

//Gallery clasess
let ACTIVITY_FEED_CLASS_NAME = "ActivityFeed"
let ACTIVITY_FEED_FILE = "file"
let ACTIVITY_FEED_CAPTION = "caption"
let ACTIVITY_FEED_BY_USER = "owner"
//Faves
let ACTIVITY_FAVES_CLASS_NAME = "activityfav"
let ACTIVITY_FAVES_BY_USER = "user"
let ACTIVITY_FAVES_FOR_FEED = "activity_feed"
let ACTIVITY_FAVES_FOR_FEED_ID = "activity_Id"
//Comments
let COMMENT_CLASS_NAME = "comments"
let COMMENT_ACTIVITY_FEED = "activity_feed"
let COMMENT_ACTIVITY_FEED_ID = "activity_Id"
let COMMENT_CONTENT = "content"
let COMMENT_BY_USER = "user_comment"

//Listings
let LISTING_CLASS_NAME = "listing"
let LISTING_PRODUCT_TITLE = "product_title"
let LISTING_PRODUCT_PHOTOS = "product_photo"
let LISTING_PRODUCT_COUNT_PHOTOS = "product_count_photo"
let LISTING_PRODUCT_GENDER = "product_gender"
let LISTING_PRODUCT_CATEGORY = "product_category"
let LISTING_PRODUCT_SIZE = "product_size"
let LISTING_PRODUCT_BRAND = "product_brand"
let LISTING_PRODUCT_CONDITION = "product_condition"
let LISTING_PRODUCT_DESCRIPTION = "product_description"
let LISTING_PRODUCT_CACULATE_SHIPPING = "product_calculate_shipping"
let LISTING_PRODUCT_LISTING_PRICE = "product_list_price"
let LISTING_PRODUCT_WILL_MAKE_PRICE = "product_will_make_price"
let LISTING_PRODUCT_OWNER = "product_owner"

//Shopping cart
let SHOPPING_CART_CLASS_NAME = "shopping_cart"
let SHOPPING_CART_LISTING_ID = "listingId"
let SHOPPING_CART_STATUS = "status"
let SHOPPING_CART_OF_USER_ID = "shoppingByUserId"

// Properties classes
let PROP_CLASS_NAME = "Properties"
let PROP_TITLE = "title"
let PROP_IMAGE = "image"
let PROP_IMAGE2 = "image2"
let PROP_IMAGE3 = "image3"
let PROP_SQUARE_METERS = "squareMeters"
let PROP_DESCRIPTION = "description"
let PROP_PRICE = "price"
let PROP_TYPE = "type"
let PROP_ACTION = "action"
let PROP_ADDRESS = "address"
let PROP_ADDRESS_LOWERCASE = "addressLowercase"
let PROP_DETAILS = "details"
let PROP_SELLER_POINTER = "sellerPointer"


// Favorites classes
let FAV_CLASS_NAME = "Favorites"
let FAV_PROPERTY = "propertyPointer"
let FAV_USER = "userPointer"

