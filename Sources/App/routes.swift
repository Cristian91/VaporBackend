import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    router.get("api", "acronyms") { (request) -> Future<[Acronym]> in
        return Acronym.query(on: request).all()
    }
    
    router.post("api", "acronyms") { request -> Future<Acronym> in
        return try request.content.decode(Acronym.self).flatMap(to: Acronym.self, { (acronym) -> EventLoopFuture<Acronym> in
            return acronym.save(on: request)
        })
    }
    
    // get by id
    router.get("api", "acronyms", Acronym.parameter) { (request) -> Future<Acronym> in
        return try request.parameters.next(Acronym.self)
    }
    
    // update
    router.put("api","acronyms", Acronym.parameter) { (request) -> Future<Acronym> in
        
        return try flatMap(to: Acronym.self,
                           request.parameters.next(Acronym.self),
                           request.content.decode(Acronym.self), { (acronym, updatedAcronym) in
                            
                            acronym.short = updatedAcronym.short
                            acronym.long = updatedAcronym.long
                            
                            return acronym.save(on: request)
        })
    }
    
    // delete
    router.delete("api", "acronyms", Acronym.parameter) { (request) -> Future<HTTPStatus> in
        return try request.parameters.next(Acronym.self).delete(on: request).transform(to: HTTPStatus.noContent)
    }
    
    // search by long or short
    router.get("api", "acronyms", "search") { (request) -> Future<[Acronym]> in
        guard let searchTerm = request.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        
        return Acronym.query(on: request).group(.or) { (or) in
            or.filter(\.short == searchTerm)
            or.filter(\.long == searchTerm)
        }.all()
//        return Acronym.query(on: request).filter(\.short == searchTerm).all()
    }
    
    // first result
    
    router.get("api", "acronyms", "first") { (request) -> Future<Acronym> in
        
        return Acronym.query(on: request).first().map(to: Acronym.self) { acronym in
            guard let acronym = acronym else {
                throw Abort(.notFound)
            }
            
            return acronym
        }
    }
    
    router.get("api", "acronyms", "sorted") { (request) -> Future<[Acronym]> in
        
        return Acronym.query(on: request).sort(\.short, .ascending).all()
    }
}

