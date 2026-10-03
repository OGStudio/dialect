import Foundation

func llmSetAsync(
    _ key: String,
    _ value: Any
) {
    DispatchQueue.main.async {
        llmSet(key, value)
    }
}
