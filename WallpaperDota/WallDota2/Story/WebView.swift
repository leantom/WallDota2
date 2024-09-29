import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var htmlContent: String
    @Binding var webViewHeight: CGFloat

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(parent: WebView) {
            self.parent = parent
        }

        // Observe when the web content size changes
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Recalculate height after content is fully loaded
            webView.evaluateJavaScript("document.documentElement.scrollHeight") { (result, error) in
                if let height = result as? NSNumber {
                    DispatchQueue.main.async {
                        // Convert NSNumber to CGFloat
                        self.parent.webViewHeight = CGFloat(height.doubleValue)
                    }
                }
            }
        }

        // Additional check for dynamic content like images
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.documentElement.scrollHeight") { (result, error) in
                if let height = result as? NSNumber {
                    DispatchQueue.main.async {
                        self.parent.webViewHeight = CGFloat(height.doubleValue)
                    }
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}
