//
//  Settings.swift
//  QLMardown
//
//  Created by Sbarex on 13/12/20.
//

import Foundation
import OSLog

enum CMARK_Error: Error {
    case parser_create
    case parser_parse
}

enum Appearance: Int {
    case undefined
    case light
    case dark
}

@objc enum GuessEngine: Int {
    case none
    case fast
    case accurate
}

class Settings {
    static let Domain: String = "org.sbarex.qlmarkdown"
    
    static let shared = Settings()
    
    @objc var tableExtension: Bool = true
    @objc var autoLinkExtension: Bool = true
    @objc var tagFilterExtension: Bool = true
    @objc var taskListExtension: Bool = true
    @objc var mentionExtension: Bool = false
    @objc var checkboxExtension: Bool = false
    
    @objc var strikethroughExtension: Bool = true
    @objc var strikethroughDoubleTildeOption: Bool = false
    
    @objc var syntaxHighlightExtension: Bool = true
    @objc var syntaxThemeLight: String = "edit-xcode"
    @objc var syntaxBackgroundColorLight: String = ""
    @objc var syntaxThemeDark: String = ""
    @objc var syntaxBackgroundColorDark: String = "neon"
    @objc var syntaxWordWrapOption: Int = 0
    @objc var syntaxLineNumbersOption: Bool = false
    @objc var syntaxTabsOption: Int = 4
    @objc var syntaxFontFamily: String = ""
    @objc var syntaxFontSize: CGFloat = 10
    
    @objc var emojiExtension: Bool = true
    @objc var emojiImageOption: Bool = false
    @objc var inlineImageExtension: Bool = false
    
    @objc var hardBreakOption: Bool = false
    @objc var noSoftBreakOption: Bool = false
    @objc var unsafeHTMLOption: Bool = false
    @objc var validateUTFOption: Bool = false
    @objc var smartQuotesOption: Bool = false
    @objc var footnotesOption: Bool = false
    
    @objc var customCSS: URL?
    @objc var customCSSOverride: Bool = false
    
    @objc var debug: Bool = false
    
    @objc var guessEngine: GuessEngine = .none
    @objc var openInlineLink: Bool = false
    
    class var applicationSupportUrl: URL? {
        let sharedContainerURL: URL? = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Domain)?.appendingPathComponent("Library/Application Support")
        return sharedContainerURL
        
        // return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent("QLMarkdown")
    }
    
    class var stylesFolder: URL? {
        return Settings.applicationSupportUrl?.appendingPathComponent("styles")
    }
    
    class var themesFolder: URL? {
        return Settings.applicationSupportUrl?.appendingPathComponent("themes")
    }
    
    private init() {
        self.reset()
    }
    
    func reset() {
        print("Shared preferences stored in \(Settings.applicationSupportUrl?.path ?? "??").")
        
        let defaults = UserDefaults.standard
        // let d = UserDefaults(suiteName: Settings.Domain)
        // Remember that macOS store the precerences inside a cache. If you manual edit the preferences file you need to reset this cache:
        // $ killall -u $USER cfprefsd
        let defaultsDomain = defaults.persistentDomain(forName: Settings.Domain) ?? [:]
        if let ext = defaultsDomain["table"] as? Bool {
            tableExtension = ext
        }
        if let ext = defaultsDomain["autolink"] as? Bool {
            autoLinkExtension = ext
        }
        if let ext = defaultsDomain["tagfilter"] as? Bool {
            tagFilterExtension = ext
        }
        if let ext = defaultsDomain["tasklist"] as? Bool {
            taskListExtension = ext
        }
        if let ext = defaultsDomain["strikethrough"] as? Bool {
            strikethroughExtension = ext
        }
        if let ext = defaultsDomain["strikethrough_doubletilde"] as? Bool {
            strikethroughDoubleTildeOption = ext
        }
        
        if let ext = defaultsDomain["mention"] as? Bool {
            mentionExtension = ext
        }
        if let ext = defaultsDomain["checkbox"] as? Bool {
            checkboxExtension = ext
        }
        if let ext = defaultsDomain["syntax"] as? Bool {
            syntaxHighlightExtension = ext
        }
        if let theme = defaultsDomain["syntax_light_theme"] as? String {
            syntaxThemeLight = theme
        }
        if let color = defaultsDomain["syntax_light_background"] as? String {
            syntaxBackgroundColorLight = color
        }
        if let theme = defaultsDomain["syntax_dark_theme"] as? String {
            syntaxThemeDark = theme
        }
        if let color = defaultsDomain["syntax_dark_background"] as? String {
            syntaxBackgroundColorDark = color
        }
        if let characters = defaultsDomain["syntax_word_wrap"] as? Int {
            syntaxWordWrapOption = characters
        }
        if let state = defaultsDomain["syntax_line_numbers"] as? Bool {
            syntaxLineNumbersOption = state
        }
        if let n = defaultsDomain["syntax_tabs"] as? Int {
            syntaxTabsOption = n
        }
        if let font = defaultsDomain["syntax_font_name"] as? String {
            syntaxFontFamily = font
        }
        if let size = defaultsDomain["syntax_font_size"] as? CGFloat {
            syntaxFontSize = size
        }
        
        if let ext = defaultsDomain["emoji"] as? Bool {
            emojiExtension = ext
        }
        
        if let ext = defaultsDomain["inlineimage"] as? Bool {
            inlineImageExtension = ext
        }
        
        if let opt = defaultsDomain["emoji_image"] as? Bool {
            emojiImageOption = opt
        }
        
        if let opt = defaultsDomain["hardbreak"] as? Bool {
            hardBreakOption = opt
        }
        if let opt = defaultsDomain["nosoftbreak"] as? Bool {
            noSoftBreakOption = opt
        }
        if let opt = defaultsDomain["unsafeHTML"] as? Bool {
            unsafeHTMLOption = opt
        }
        if let opt = defaultsDomain["validateUTF"] as? Bool {
            validateUTFOption = opt
        }
        if let opt = defaultsDomain["smartquote"] as? Bool {
            smartQuotesOption = opt
        }
        if let opt = defaultsDomain["footnote"] as? Bool {
            footnotesOption = opt
        }
        
        if let opt = defaultsDomain["customCSS"] as? String, !opt.isEmpty {
            if !opt.hasPrefix("/"), let path = Settings.stylesFolder {
                customCSS = path.appendingPathComponent(opt)
            } else {
                customCSS = URL(fileURLWithPath: opt)
            }
        }
        if let opt = defaultsDomain["customCSS-override"] as? Bool {
            customCSSOverride = opt
        }
        
        if let opt = defaultsDomain["guess-engine"] as? Int, let guess = GuessEngine(rawValue: opt) {
            guessEngine = guess
        }
        
        if let opt = defaultsDomain["debug"] as? Bool {
            debug = opt
        }
        
        if let opt = defaultsDomain["inline-link"] as? Bool {
            openInlineLink = opt
        }
        
        sanitizeEmojiOption()
    }
    
    private func sanitizeEmojiOption() {
        if emojiExtension && emojiImageOption {
            unsafeHTMLOption = true
        }
    }
    
    func getCustomCSSCode() -> String? {
        guard let url = self.customCSS else {
            return nil
        }
        return try? String(contentsOf: url)
    }
    
    func render(file url: URL, forAppearance appearance: Appearance, baseDir: String?, log: OSLog? = nil) throws -> String {
        guard let data = FileManager.default.contents(atPath: url.path), let markdown_string = String(data: data, encoding: .utf8) else {
            return ""
        }
        
        return try self.render(text: markdown_string, forAppearance: appearance, baseDir: baseDir ?? url.deletingLastPathComponent().path, log: log)
    }
    
    func render(text: String, forAppearance appearance: Appearance, baseDir: String, log: OSLog? = nil) throws -> String {
        cmark_gfm_core_extensions_ensure_registered()
        
        var options = CMARK_OPT_DEFAULT
        if self.unsafeHTMLOption || (self.emojiExtension && self.emojiImageOption) {
            options |= CMARK_OPT_UNSAFE
        }
        
        if self.hardBreakOption {
            options |= CMARK_OPT_HARDBREAKS
        }
        if self.noSoftBreakOption {
            options |= CMARK_OPT_NOBREAKS
        }
        if self.validateUTFOption {
            options |= CMARK_OPT_VALIDATE_UTF8
        }
        if self.smartQuotesOption {
            options |= CMARK_OPT_SMART
        }
        if self.footnotesOption {
            options |= CMARK_OPT_FOOTNOTES
        }
        
        if self.strikethroughExtension && self.strikethroughDoubleTildeOption {
            options |= CMARK_OPT_STRIKETHROUGH_DOUBLE_TILDE
        }
        
        if let l = log {
            os_log(
                "cmark_gfm options: %{public}d.",
                log: l,
                type: .debug,
                options
            )
        }
        
        guard let parser = cmark_parser_new(options) else {
            if let l = log {
                os_log(
                    "Unable to create new cmark_parser!",
                    log: l,
                    type: .error,
                    options
                )
            }
            throw CMARK_Error.parser_create
        }
        defer {
            cmark_parser_free(parser)
        }
        
        if self.tableExtension, let ext = cmark_find_syntax_extension("table") {
            cmark_parser_attach_syntax_extension(parser, ext)
            if let l = log {
                os_log(
                    "Enabled markdown `table` extension.",
                    log: l,
                    type: .debug
                )
            }
        }
        
        if self.autoLinkExtension, let ext = cmark_find_syntax_extension("autolink") {
            cmark_parser_attach_syntax_extension(parser, ext)
            if let l = log {
                os_log(
                    "Enabled markdown `autolink` extension.",
                    log: l,
                    type: .debug
                )
            }
        }
        
        if self.tagFilterExtension, let ext = cmark_find_syntax_extension("tagfilter") {
            cmark_parser_attach_syntax_extension(parser, ext)
            if let l = log {
                os_log(
                    "Enabled markdown `tagfilter` extension.",
                    log: l,
                    type: .debug
                )
            }
        }
        
        if self.taskListExtension, let ext = cmark_find_syntax_extension("tasklist") {
            cmark_parser_attach_syntax_extension(parser, ext)
            if let l = log {
                os_log(
                    "Enabled markdown `tasklist` extension.",
                    log: l,
                    type: .debug
                )
            }
        }
        
        if self.strikethroughExtension, let ext = cmark_find_syntax_extension("strikethrough") {
            cmark_parser_attach_syntax_extension(parser, ext)
            if let l = log {
                os_log(
                    "Enabled markdown `strikethrough` extension.",
                    log: l,
                    type: .debug
                )
            }
        }
        
        if self.mentionExtension, let ext = cmark_find_syntax_extension("mention") {
            cmark_parser_attach_syntax_extension(parser, ext)
            if let l = log {
                os_log(
                    "Enabled markdown `mention` extension.",
                    log: l,
                    type: .debug
                )
            }
        }
        
        if self.inlineImageExtension, let ext = cmark_find_syntax_extension("inlineimage") {
            cmark_parser_attach_syntax_extension(parser, ext)
            cmark_syntax_extension_inlineimage_set_wd(ext, baseDir.cString(using: .utf8))
            if let l = log {
                os_log(
                    "Enabled markdown `local inline image` extension with working path set to `%{public}s.",
                    log: l,
                    type: .debug,
                    baseDir
                )
            }
        }
        
        if self.emojiExtension, let ext = cmark_find_syntax_extension("emoji") {
            cmark_syntax_extension_emoji_set_use_characters(ext, !self.emojiImageOption)
            cmark_parser_attach_syntax_extension(parser, ext)
            if let l = log {
                os_log(
                    "Enabled markdown `emoji` extension using %{public}%s.",
                    log: l,
                    type: .debug,
                    self.emojiImageOption ? "images" : "glyphs"
                )
            }
        }
        
        if self.syntaxHighlightExtension, let ext = cmark_find_syntax_extension("syntaxhighlight") {
            // TODO: set a property
            if let path = Bundle.main.resourceURL?.appendingPathComponent("highlight").path {
                cmark_syntax_highlight_init("\(path)/".cString(using: .utf8))
            }
            
            let theme: String
            let background: String
            switch appearance {
            case .light:
                theme = self.syntaxThemeLight
                background = self.syntaxBackgroundColorLight
            case .dark:
                theme = self.syntaxThemeDark
                background = self.syntaxBackgroundColorDark
            case .undefined:
                let mode = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
                if mode == "Light" {
                    theme = self.syntaxThemeLight
                    background = self.syntaxBackgroundColorLight
                } else {
                    theme = self.syntaxThemeDark
                    background = self.syntaxBackgroundColorDark
                }
            }
            
            cmark_syntax_extension_highlight_set_theme_name(ext, theme)
            cmark_syntax_extension_highlight_set_background_color(ext, background.isEmpty ? nil : background)
            cmark_syntax_extension_highlight_set_line_number(ext, self.syntaxLineNumbersOption ? 1 : 0)
            cmark_syntax_extension_highlight_set_tab_spaces(ext, Int32(self.syntaxTabsOption))
            cmark_syntax_extension_highlight_set_wrap_limit(ext, Int32(self.syntaxWordWrapOption))
            cmark_syntax_extension_highlight_set_guess_language(ext, guess_type(UInt32(self.guessEngine.rawValue)))
            if self.guessEngine == .fast, let f = Bundle.main.path(forResource: "magic", ofType: "mgc") {
                cmark_syntax_extension_highlight_set_magic_file(ext, f)
            }
            
            if !self.syntaxFontFamily.isEmpty {
                cmark_syntax_extension_highlight_set_font_family(ext, self.syntaxFontFamily, Float(self.syntaxFontSize))
            } else {
                // cmark_syntax_extension_highlight_set_font_family(ext, "-apple-system, BlinkMacSystemFont, sans-serif", 0.0)
                // Pass a fake value, so will be used the font defined inside the main css file.
                cmark_syntax_extension_highlight_set_font_family(ext, "-", 0.0)
            }
            
            cmark_parser_attach_syntax_extension(parser, ext)
            
            if let l = log {
                os_log(
                    "Enabled markdown `syntax highlight` extension.\n Theme: %{public}s, background color: %{public}s",
                    log: l,
                    type: .debug,
                    theme, background
                )
            }
        }
        
        cmark_parser_feed(parser, text, strlen(text))
        guard let doc = cmark_parser_finish(parser) else {
            throw CMARK_Error.parser_parse
        }
        defer {
            cmark_node_free(doc)
        }
        
        let html_debug = self.renderDebugInfo(forAppearance: appearance, baseDir: baseDir)
        // Render
        if let html2 = cmark_render_html(doc, options, nil) {
            defer {
                free(html2)
            }
            
            return html_debug + String(cString: html2)
        } else {
            return html_debug + "<p>RENDER FAILED!</p>"
        }
    }
    
    internal func renderDebugInfo(forAppearance appearance: Appearance, baseDir: String) -> String
    {
        guard debug else {
            return ""
        }
        var html_debug = ""
        html_debug += """
<style type="text/css">
table.debug td {
    vertical-align: top;
    font-size: .8rem;
}
</style>
"""
        html_debug += "<table class='debug'>\n<caption>Debug info</caption>"
        var html_options = ""
        if self.unsafeHTMLOption || (self.emojiExtension && self.emojiImageOption) {
            html_options += "CMARK_OPT_UNSAFE "
        }
        
        if self.hardBreakOption {
            html_options += "CMARK_OPT_HARDBREAKS "
        }
        if self.noSoftBreakOption {
            html_options += "CMARK_OPT_NOBREAKS "
        }
        if self.validateUTFOption {
            html_options += "CMARK_OPT_VALIDATE_UTF8 "
        }
        if self.smartQuotesOption {
            html_options += "CMARK_OPT_SMART "
        }
        if self.footnotesOption {
            html_options += "CMARK_OPT_FOOTNOTES "
        }
        
        if self.strikethroughExtension && self.strikethroughDoubleTildeOption {
            html_options += "CMARK_OPT_STRIKETHROUGH_DOUBLE_TILDE "
        }

        html_debug += "<tr><td>options</td><td>\(html_options)</td></tr>\n"
        
        html_debug += "<tr><td>table extension</td><td>"
        if self.tableExtension {
            html_debug += "on " + (cmark_find_syntax_extension("table") == nil ? " (NOT AVAILABLE" : "")
        } else {
            html_debug += "off"
        }
        html_debug += "</td></tr>\n"

        html_debug += "<tr><td>autolink extension</td><td>"
        if self.autoLinkExtension {
            html_debug += "on " + (cmark_find_syntax_extension("autolink") == nil ? " (NOT AVAILABLE" : "")
        } else {
            html_debug += "off"
        }
        html_debug += "</td></tr>\n"
        
        html_debug += "<tr><td>tagfilter extension</td><td>"
        if self.tagFilterExtension {
            html_debug += "on " + (cmark_find_syntax_extension("tagfilter") == nil ? " (NOT AVAILABLE" : "")
        } else {
            html_debug += "off"
        }
        html_debug += "</td></tr>\n"

        html_debug += "<tr><td>tasklist extension</td><td>"
        if self.taskListExtension {
            html_debug += "on " + (cmark_find_syntax_extension("tasklist") == nil ? " (NOT AVAILABLE" : "")
        } else {
            html_debug += "off"
        }
        html_debug += "</td></tr>\n"
        
        html_debug += "<tr><td>strikethrough extension</td><td>"
        if self.strikethroughExtension {
            html_debug += "on " + (cmark_find_syntax_extension("strikethrough") == nil ? " (NOT AVAILABLE" : "")
        } else {
            html_debug += "off"
        }
        html_debug += "</td></tr>\n"
        
        html_debug += "<tr><td>mention extension</td><td>"
        if self.mentionExtension {
            html_debug += "on " + (cmark_find_syntax_extension("mention") == nil ? " (NOT AVAILABLE" : "")
        } else {
            html_debug += "off"
        }
        html_debug += "</td></tr>\n"
        
        html_debug += "<tr><td>inlineimage extension</td><td>"
        if self.inlineImageExtension {
            html_debug += "on" + (cmark_find_syntax_extension("inlineimage") == nil ? " (NOT AVAILABLE" : "")
            html_debug += "<br />basedir: \(baseDir)"
        } else {
            html_debug += "off"
        }
        html_debug += "</td></tr>\n"
        
        html_debug += "<tr><td>emoji extension</td><td>"
        if self.emojiExtension {
            html_debug += "on" + (cmark_find_syntax_extension("emoji") == nil ? " (NOT AVAILABLE" : "")
            html_debug += " / \(self.emojiImageOption ? "using images" : "using emoji")"
        } else {
            html_debug += "off"
        }
        html_debug += "</td></tr>\n"
        
        html_debug += "<tr><td>source code highlight</td><td>"
        if self.syntaxHighlightExtension {
            html_debug += "on " + (cmark_find_syntax_extension("syntaxhighlight") == nil ? " (NOT AVAILABLE" : "")
            
            let theme: String
            var background: String
            switch appearance {
            case .light:
                theme = self.syntaxThemeLight
                background = self.syntaxBackgroundColorLight
            case .dark:
                theme = self.syntaxThemeDark
                background = self.syntaxBackgroundColorDark
            case .undefined:
                let mode = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
                if mode == "Light" {
                    theme = self.syntaxThemeLight
                    background = self.syntaxBackgroundColorLight
                } else {
                    theme = self.syntaxThemeDark
                    background = self.syntaxBackgroundColorDark
                }
            }
            if background.isEmpty {
                background = "use theme settings"
            } else if background == "ignore" {
                background = "use markdown settings"
            }
            
            html_debug += "<table>\n"
            html_debug += "<tr><td>datadir</td><td>\(Bundle.main.resourceURL?.appendingPathComponent("highlight").path ?? "missing")</td></tr>\n"
            html_debug += "<tr><td>theme</td><td>\(theme)</td></tr>\n"
            html_debug += "<tr><td>background</td><td>\(background)</td></tr>\n"
            html_debug += "<tr><td>line numbers</td><td>\(self.syntaxLineNumbersOption ? "on" : "off")</td></tr>\n"
            html_debug += "<tr><td>spaces for a tab</td><td>\(self.syntaxTabsOption)</td></tr>\n"
            html_debug += "<tr><td>wrap</td><td> \(self.syntaxWordWrapOption > 0 ? "after \(self.syntaxWordWrapOption) characters" : "disabled")</td></tr>\n"
            html_debug += "<tr><td>spaces for a tab</td><td>\(self.syntaxTabsOption)</td></tr>\n"
            html_debug += "<tr><td>guess language</td><td>"
            switch self.guessEngine {
            case .none:
                html_debug += "off"
            case .fast:
                html_debug += "fast<br />"
                html_debug += "magic db: \(Bundle.main.path(forResource: "magic", ofType: "mgc") ?? "missing")"
            case .accurate:
                html_debug += "accurate"
            }
            html_debug += "</td></tr>\n"
            html_debug += "<tr><td>font family</td><td>\(self.syntaxFontFamily.isEmpty ? "not set" : self.syntaxFontFamily)</td></tr>\n"
            html_debug += "<tr><td>font size</td><td>\(self.syntaxFontSize > 0 ? "\(self.syntaxFontSize)" : "not set")</td></tr>\n"
            html_debug += "</table>\n"
        } else {
            html_debug += "off"
        }
        html_debug += "</td></tr>\n"
        
        html_debug += "<tr><td>link</td><td>" + (self.openInlineLink ? "open inline" : "open in standard browser") + "</td></tr>\n"
        
        html_debug += "</table>\n"
        
        return html_debug
    }
    
    internal func getBundleContents(forResource: String, ofType: String) -> String?
    {
        if let p = Bundle.main.path(forResource: forResource, ofType: ofType), let data = FileManager.default.contents(atPath: p), let s = String(data: data, encoding: .utf8) {
            return s
        } else {
            return nil
        }
    }
    
    func getCompleteHTML(title: String, body: String, header: String = "", footer: String = "") -> String {
        let css_doc: String
        let css_doc_extended: String
        
        let formatCSS = { (code: String?) -> String in
            guard let css = code, !css.isEmpty else {
                return ""
            }
            return "<style type='text/css'>\(css)\n</style>\n"
        }
        
        if let css = self.getCustomCSSCode() {
            css_doc_extended = formatCSS(css)
            if !self.customCSSOverride {
                css_doc = formatCSS(getBundleContents(forResource: "markdown", ofType: "css"))
            } else {
                css_doc = ""
            }
        } else {
            css_doc_extended = ""
            css_doc = formatCSS(getBundleContents(forResource: "markdown", ofType: "css"))
        }
        // css_doc = "<style type=\"text/css\">\n\(css_doc)\n</style>\n"
            
        var css_highlight: String
        if self.syntaxHighlightExtension, let ext = cmark_find_syntax_extension("syntaxhighlight"), cmark_syntax_extension_highlight_get_rendered_count(ext) > 0, let p = cmark_syntax_extension_get_style(ext) {
            
            let font = self.syntaxFontFamily
            css_highlight = String(cString: p)
            if font != "" {
                css_highlight += """
:root {
  --code-font: "\(font)", -apple-system, Menlo, monospace;
}
""";
            }
            css_highlight = formatCSS(css_highlight);
            p.deallocate();
        } else {
            css_highlight = ""
        }
        
        let style = css_doc + css_highlight + css_doc_extended
        
        let html =
"""
<!doctype html>
<html>
<head>
<meta charset='utf-8'>
<meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0'>
<title>\(title)</title>
\(style)
\(header)
</head>
<body class="markdown-body">
\(body)
\(footer)
</body>
</html>
"""
        return html
    }
}
