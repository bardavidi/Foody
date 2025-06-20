package org.foody.project

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.navigation.NavHostController


sealed class BottomNavItem(val label: String, val icon: ImageVector) {
    object Main : BottomNavItem("Main", Icons.Default.Home)
    object Favorites : BottomNavItem("Favorites", Icons.Default.Favorite)
    object Location : BottomNavItem("Location", Icons.Default.LocationOn)
    object Category : BottomNavItem("Category", Icons.Default.Menu)
}

@Composable
fun MainScreen(
    restaurants: List<places.Restaurant>,
    navController: NavHostController
) {
    var selectedItem by remember { mutableStateOf<BottomNavItem>(BottomNavItem.Main) }

    Scaffold(
        bottomBar = {
            NavigationBar {
                listOf(
                    BottomNavItem.Main,
                    BottomNavItem.Favorites,
                    BottomNavItem.Location,
                    BottomNavItem.Category
                ).forEach { item ->
                    NavigationBarItem(
                        icon = { Icon(item.icon, contentDescription = item.label) },
                        label = { Text(item.label) },
                        selected = selectedItem == item,
                        onClick = { selectedItem = item }
                    )
                }
            }
        }
    ) { padding ->
        Box(modifier = Modifier.padding(padding)) {
            when (selectedItem) {
                is BottomNavItem.Main -> RestaurantScreen(
                    restaurants = restaurants,
                    onRestaurantClick = { restaurant ->
                        navController.navigate("details/${restaurant.id}")
                    }
                )
                is BottomNavItem.Favorites -> Text("Favorites Screen")
                is BottomNavItem.Location -> Text("Filter by Location")
                is BottomNavItem.Category -> Text("Filter by Category")
            }
        }
    }
}


