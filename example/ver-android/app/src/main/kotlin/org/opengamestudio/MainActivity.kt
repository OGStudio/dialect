package org.opengamestudio

import android.graphics.Color
import android.os.Bundle
import androidx.activity.*
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.ui.*
import androidx.compose.ui.graphics.Color as ComposeColor
import org.opengamestudio.ui.theme.MyApplicationTheme

class MainActivity: ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge(
            statusBarStyle = SystemBarStyle.dark(Color.TRANSPARENT),
            navigationBarStyle = SystemBarStyle.dark(Color.TRANSPARENT),
        )

        //VM.androidContext = this
        // Launch components once VM has Android context
        //LogComponent.setupLogging(rootCtrl(), "Root")
        //RootComponent.setup()

        setContent {
            MyApplicationTheme {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(ComposeColor.White),
                    contentAlignment = Alignment.Center
                ) {
                    Text("Hello, world")
                }
            }
        }
    }
}
