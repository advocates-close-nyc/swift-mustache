import XCTest
@testable import HummingbirdMustache

final class TemplateParserTests: XCTestCase {
    func testText() throws {
        let template = try HBMustacheTemplate(string: "test template")
        XCTAssertEqual(template.tokens, [.text("test template")])
    }

    func testVariable() throws {
        let template = try HBMustacheTemplate(string: "test {{variable}}")
        XCTAssertEqual(template.tokens, [.text("test "), .variable("variable")])
    }

    func testSection() throws {
        let template = try HBMustacheTemplate(string: "test {{#section}}text{{/section}}")
        XCTAssertEqual(template.tokens, [.text("test "), .section("section", .init([.text("text")]))])
    }

    func testInvertedSection() throws {
        let template = try HBMustacheTemplate(string: "test {{^section}}text{{/section}}")
        XCTAssertEqual(template.tokens, [.text("test "), .invertedSection("section", .init([.text("text")]))])
    }

    func testComment() throws {
        let template = try HBMustacheTemplate(string: "test {{!section}}")
        XCTAssertEqual(template.tokens, [.text("test ")])
    }

    func testWhitespace() throws {
        let template = try HBMustacheTemplate(string: "{{ section }}")
        XCTAssertEqual(template.tokens, [.variable("section")])
    }

    func testSectionEndError() throws {
        XCTAssertThrowsError(_ = try HBMustacheTemplate(string: "test {{#section}}")) { error in
            switch error {
            case HBMustacheTemplate.Error.expectedSectionEnd:
                break
            default:
                XCTFail("\(error)")
            }
        }
    }

    func testSectionCloseNameIncorrectError() throws {
        XCTAssertThrowsError(_ = try HBMustacheTemplate(string: "test {{#section}}{{/error}}")) { error in
            switch error {
            case HBMustacheTemplate.Error.sectionCloseNameIncorrect:
                break
            default:
                XCTFail("\(error)")
            }
        }
    }

    func testUnmatchedNameError() throws {
        XCTAssertThrowsError(_ = try HBMustacheTemplate(string: "test {{section#}}")) { error in
            switch error {
            case HBMustacheTemplate.Error.unfinishedName:
                break
            default:
                XCTFail("\(error)")
            }
        }
    }
}

extension HBMustacheTemplate: Equatable {
    public static func == (lhs: HBMustacheTemplate, rhs: HBMustacheTemplate) -> Bool {
        lhs.tokens == rhs.tokens
    }
}

extension HBMustacheTemplate.Token: Equatable {
    public static func == (lhs: HBMustacheTemplate.Token, rhs: HBMustacheTemplate.Token) -> Bool {
        switch (lhs, rhs) {
        case (.text(let lhs), .text(let rhs)):
            return lhs == rhs
        case (.variable(let lhs, let lhs2), .variable(let rhs, let rhs2)):
            return lhs == rhs && lhs2 == rhs2
        case (.section(let lhs1, let lhs2), .section(let rhs1, let rhs2)):
            return lhs1 == rhs1 && lhs2 == rhs2
        case (.invertedSection(let lhs1, let lhs2), .invertedSection(let rhs1, let rhs2)):
            return lhs1 == rhs1 && lhs2 == rhs2
        default:
            return false
        }
    }
}
