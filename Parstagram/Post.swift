//
//  Post.swift
//  Parstagram
//
//  Created by Will Tyler on 2/13/19.
//  Copyright © 2019 Parstagram. All rights reserved.
//

import Foundation
import Firebase


struct Post {

	let id: String
	let caption: String
	let authorID: String
	let date: Date
	var comments: [Comment]? {
		didSet {
			didSetComments?()
		}
	}
	private let data = NSMutableData()
	var pngData: Data? {
		get {
			return data as Data?
		}
		set {
			data.setData(pngData ?? Data())
		}
	}
	var didSetComments: (()->())?

	init(id: String, caption: String, authorID: String, date: Date, pngData: Data? = nil, comments: [Comment]? = nil) {
		self.id = id
		self.caption = caption
		self.authorID = authorID
		self.date = date
		self.comments = comments

		if let pngData = pngData {
			self.data.setData(pngData)
		}
	}

	func handlePNGData(with handler: @escaping (Data?, Error?)->()) {
		if let data = pngData, !data.isEmpty {
			handler(data, nil)
		}
		else {
			Firebase.handlePNGData(for: self, with: { (data, error) in
				if let data = data {
					self.data.setData(data)
				}

				handler(data, error)
			})
		}
	}

	func post(comment: Comment) {
		let db = Firestore.firestore()
		let commentsRef = db.collection("users").document(authorID).collection("posts").document(id)
		let data = [
			"authorID": comment.authorID,
			"content": comment.content
		]

		commentsRef.updateData([
			"comments": FieldValue.arrayUnion([data])
		])
	}

}
