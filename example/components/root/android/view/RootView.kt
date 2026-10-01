package org.opengamestudio

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.*
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.*

@Composable
fun RootView() {
    Column(
        verticalArrangement = Arrangement.spacedBy(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier.padding(40.dp)
    ) {
        Text(
            text = "Hello, World!",
            fontSize = 32.sp
        )

        Text(
            text = RootVM.countText,
            fontFamily = FontFamily.Monospace
        )

        Button(
            onClick = { rootSet(F.didClickIncrement, true) }
        ) {
            Text("Increment")
        }
    }
}
