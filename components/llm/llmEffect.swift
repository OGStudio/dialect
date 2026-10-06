import Foundation

func llmLoad(
    _ req: NetRequest,
    _ keyResponse: String,
    _ keyResponseError: String
) {
    netLoad(
        req,
        { res in llmSetAsync(keyResponse, res) },
        { res in llmSetAsync(keyResponseError, res) }
    )
}
