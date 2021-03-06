import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    func boot(router: Router) throws {
        let acronymRoutes = router.grouped("api", "acronyms")
        acronymRoutes.get(use: getAllHandler)
        acronymRoutes.post(Acronym.self, use: createHandler)
        acronymRoutes.get(Acronym.parameter, use: getHandler)
        acronymRoutes.put(Acronym.parameter, use: updateHandler)
        acronymRoutes.delete(Acronym.parameter, use: deleteHandler)
        acronymRoutes.get("search", use: searchHandler)
        acronymRoutes.get("first", use: getFirstHandler)
        acronymRoutes.get("sorted", use: sortedHandler)
        acronymRoutes.get(Acronym.parameter, "user", use: getUserHandler)
    }
    
    func getAllHandler(_ request: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: request).all()
    }
    func createHandler(_ req: Request, acronym: Acronym) throws -> Future<Acronym> {
        return try req
            .content
            .decode(Acronym.self)
            .flatMap(to: Acronym.self) { acronym in
                return acronym.save(on: req)
        } }
    func getHandler(_ req: Request) throws -> Future<Acronym> {
        return try req.parameters.next(Acronym.self)
    }
    func updateHandler(_ req: Request) throws -> Future<Acronym> {
        return try flatMap(
            to: Acronym.self,
            req.parameters.next(Acronym.self),
            req.content.decode(Acronym.self)
        ) { acronym, updatedAcronym in
            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long
            acronym.userID = updatedAcronym.userID
            return acronym.save(on: req)
        }
    }
    func deleteHandler(_ req: Request)
        throws -> Future<HTTPStatus> {
            return try req
                .parameters
                .next(Acronym.self)
                .delete(on: req)
                .transform(to: HTTPStatus.noContent)
    }
    func searchHandler(_ req: Request) throws -> Future<[Acronym]> {
        guard let searchTerm = req
            .query[String.self, at: "term"] else {
                throw Abort(.badRequest)
        }
        return Acronym.query(on: req).group(.or) { or in
            or.filter(\.short == searchTerm)
            or.filter(\.long == searchTerm)
            }.all() }
    func getFirstHandler(_ req: Request) throws -> Future<Acronym> {
        return Acronym.query(on: req)
            .first()
            .map(to: Acronym.self) { acronym in
                guard let acronym = acronym else {
                    throw Abort(.notFound)
                }
                return acronym
        }
    }
    func sortedHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).sort(\.short, .ascending).all()
    }
    
//    func getUserHandler(_ req: Request) throws -> Future<User> {
//        return try req.parameters.next(Acronym.self).flatMap(to: User.self) { acronym in
//            acronym.user.get(on: req)
//        }
//    }
    
    func getUserHandler(_ req: Request) throws -> Future<User> {
        // 2
        return try req
            .parameters.next(Acronym.self)
            .flatMap(to: User.self) { acronym in
                // 3
                acronym.user.get(on: req)
        }
    }
}

extension Acronym: Parameter {}
