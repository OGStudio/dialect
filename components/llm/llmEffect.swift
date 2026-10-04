func llmLoad(
    _ req: NetRequest,
    _ keyResponse: String,
    _ keyResponseError: String
) {
    netLoad(
        req,
        { res in llmSetAsync(keyResponse, res) },
        { err in llmSetAsync(keyResponseError, err) }
    )
}
