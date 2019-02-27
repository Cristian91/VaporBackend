import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    router.post("api", "acronyms") { request -> Future<Acronym> in
        
//        return try request.content.decode(Acronym.self).flatMap(to: Acronym.self) { (acronym) in
//            return acronym.save(on: request)
//        }
        
        return try request.content.decode(Acronym.self).flatMap(to: Acronym.self, { (acronym) -> EventLoopFuture<Acronym> in
            return acronym.save(on: request)
        })
    }
}

