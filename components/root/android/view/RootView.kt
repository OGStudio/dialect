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
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier.padding(40.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text(
            fontSize = 32.sp,
            text = "Hello, World!"
        )

        Text(
            fontFamily = FontFamily.Monospace,
            text = RootVM.countText
        )

        Button(
            onClick = { rootSet(F.didClickIncrement, true) }
        ) {
            Text("Increment")
        }
    }
}
